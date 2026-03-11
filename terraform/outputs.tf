output "vm_default_ipv4" {
  description = "Primary IPv4 addresses for the provisioned virtual machines"
  value       = { for name, vm in proxmox_vm_qemu.vm : name => vm.default_ipv4_address }
}

output "vm_ids" {
  description = "Terraform identifiers for the created Proxmox VMs"
  value       = { for name, vm in proxmox_vm_qemu.vm : name => vm.id }
}

output "vm_details" {
  description = "Detailed information about created VMs"
  value = {
    for name, vm in proxmox_vm_qemu.vm : name => {
      id       = vm.id
      name     = vm.name
      ip       = split("/", vm.ipconfig0)[0]
      ssh_user = var.cloud_init_user
      tags     = vm.tags
    }
  }
}

output "ansible_inventory_path" {
  description = "Path to the auto-generated Ansible inventory file"
  value       = local_file.ansible_inventory.filename
}

output "next_steps" {
  description = "Instructions for next steps"
  value = <<-EOT
    Terraform has created your VMs. Next steps:
    
    1. Verify VMs are accessible:
       ssh ${var.cloud_init_user}@<vm_ip>
    
    2. Run Ansible to configure services:
       cd ../ansible
       ansible-playbook -i inventory/terraform_hosts.yml main-playbook.yml
    
    3. Or enable automatic Ansible provisioning by setting:
       run_ansible_after_apply = true
  EOT
}

