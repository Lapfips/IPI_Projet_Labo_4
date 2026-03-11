locals {
  default_vm_definitions = {
    bastion = {
      hostname    = "bastion"
      cores       = 2
      memory      = 4096
      disk_gb     = 40
      ip_cidr     = "192.168.125.1/24"
      gateway     = "192.168.125.254"
      tags        = ["bastion", "guacamole"]
      description = "Apache Guacamole bastion host"
    }
    ticketing = {
      hostname    = "ticketing"
      cores       = 4
      memory      = 6144
      disk_gb     = 60
      ip_cidr     = "192.168.125.2/24"
      gateway     = "192.168.125.254"
      tags        = ["ticketing", "glpi"]
      description = "GLPI ticketing platform"
    }
    network = {
      hostname    = "network"
      cores       = 2
      memory      = 3072
      disk_gb     = 30
      ip_cidr     = "192.168.125.3/24"
      gateway     = "192.168.125.254"
      tags        = ["network", "dhcp", "dns"]
      description = "DHCP/DNS services"
    }
    cloud = {
      hostname    = "cloud"
      cores       = 4
      memory      = 8192
      disk_gb     = 100
      ip_cidr     = "192.168.125.4/24"
      gateway     = "192.168.125.254"
      tags        = ["cloud", "nextcloud"]
      description = "Nextcloud collaboration platform"
    }
    monitoring = {
      hostname    = "monitoring"
      cores       = 4
      memory      = 8192
      disk_gb     = 80
      ip_cidr     = "192.168.125.5/24"
      gateway     = "192.168.125.254"
      tags        = ["monitoring", "zabbix"]
      description = "Zabbix monitoring server"
    }
    database = {
      hostname    = "database"
      cores       = 4
      memory      = 12288
      disk_gb     = 120
      ip_cidr     = "192.168.150.1/24"
      gateway     = "192.168.150.254"
      tags        = ["database", "postgresql"]
      description = "PostgreSQL backend for shared services"
    }
  }

  vm_definitions = length(var.vm_definitions) > 0 ? var.vm_definitions : local.default_vm_definitions

  cloud_init_authorized_keys = length(var.cloud_init_ssh_public_keys) > 0 ? join("\n", var.cloud_init_ssh_public_keys) : null

  default_nameserver = length(var.cloud_init_dns_servers) > 0 ? join(" ", var.cloud_init_dns_servers) : null
}

resource "proxmox_vm_qemu" "vm" {
  for_each = local.vm_definitions

  name        = try(each.value.hostname, each.key)
  target_node = try(each.value.target_node, var.default_target_node)
  clone       = try(each.value.template, var.base_vm_template)
  full_clone  = true
  os_type     = "cloud-init"
  agent       = var.enable_qemu_agent ? 1 : 0
  onboot      = true
  pool        = var.proxmox_pool != "" ? var.proxmox_pool : null

  sockets = try(each.value.sockets, 1)
  cores   = each.value.cores
  memory  = each.value.memory

  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    slot    = 0
    size    = format("%dG", each.value.disk_gb)
    type    = try(each.value.disk_type, "scsi")
    storage = try(each.value.disk_storage, var.vm_storage)
  }

  network {
    model    = try(each.value.network_model, "virtio")
    bridge   = try(each.value.bridge, var.vm_bridge)
    tag      = try(each.value.vlan, 0)
    firewall = try(each.value.firewall, false)
  }

  ipconfig0 = format(
    "ip=%s%s",
    each.value.ip_cidr,
    (try(each.value.gateway, null) != null && trim(try(each.value.gateway, "")) != "") ? format(",gw=%s", each.value.gateway) : ""
  )

  cloudinit_cdrom_storage = var.cloudinit_cdrom_storage
  ciuser                  = var.cloud_init_user
  cipassword              = length(var.cloud_init_password) > 0 ? var.cloud_init_password : null
  sshkeys                 = local.cloud_init_authorized_keys

  nameserver   = length(try(each.value.dns_servers, [])) > 0 ? join(" ", try(each.value.dns_servers, [])) : local.default_nameserver
  searchdomain = var.cloud_init_search_domain != "" ? var.cloud_init_search_domain : null

  notes = try(each.value.description, "")
  tags  = join(";", distinct(concat(var.default_tags, try(each.value.tags, []))))

  lifecycle {
    ignore_changes = [
      disk[0].iothread
    ]
  }

  # Ensure serial console is available for troubleshooting
  serial {
    id   = 0
    type = "socket"
  }

  # Wait for cloud-init to complete before provisioning
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait || true",
      "echo 'Cloud-init completed, VM ready for Ansible provisioning'"
    ]

    connection {
      type        = "ssh"
      user        = var.cloud_init_user
      private_key = var.ansible_private_key_path != "" ? file(var.ansible_private_key_path) : null
      host        = split("/", each.value.ip_cidr)[0]
      timeout     = "5m"
    }
  }
}

# Generate Ansible inventory dynamically from created VMs
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory/terraform_hosts.yml"
  content = templatefile("${path.module}/templates/inventory.yml.tpl", {
    vms = {
      for key, vm in proxmox_vm_qemu.vm : key => {
        hostname = vm.name
        ip       = split("/", vm.ipconfig0)[0]
        groups   = vm.tags
      }
    }
  })
  file_permission = "0644"
}

# Optionally trigger Ansible playbook after all VMs are created
resource "null_resource" "ansible_provisioning" {
  count = var.run_ansible_after_apply ? 1 : 0

  depends_on = [
    proxmox_vm_qemu.vm,
    local_file.ansible_inventory
  ]

  triggers = {
    vm_ids = join(",", [for vm in proxmox_vm_qemu.vm : vm.id])
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${var.ansible_inventory_path} ${var.ansible_playbook_path} --private-key=${var.ansible_private_key_path}"
    working_dir = "${path.module}/../ansible"
  }
}
