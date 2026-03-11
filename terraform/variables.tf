variable "pm_api_url" {
  description = "Proxmox API URL (https://proxmox.example:8006/api2/json)"
  type        = string
}

variable "pm_user" {
  description = "Proxmox username (e.g., root@pam)"
  type        = string
  default     = null
}

variable "pm_password" {
  description = "Proxmox password (if not using API token)"
  type        = string
  sensitive   = true
  default     = null
}

variable "pm_api_token_id" {
  description = "Proxmox API token ID (e.g., user@realm!token)"
  type        = string
  default     = null
}

variable "pm_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
  default     = null
}

variable "pm_tls_insecure" {
  description = "Allow invalid TLS certificates"
  type        = bool
  default     = false
}

variable "default_target_node" {
  description = "Default Proxmox node where VMs will be created"
  type        = string
}

variable "base_vm_template" {
  description = "Name of the cloud-init enabled template to clone from"
  type        = string
}

variable "vm_storage" {
  description = "Primary storage identifier for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "cloudinit_cdrom_storage" {
  description = "Storage identifier to attach the cloud-init ISO"
  type        = string
  default     = "local-lvm"
}

variable "vm_bridge" {
  description = "Default network bridge for VM network interfaces"
  type        = string
  default     = "vmbr0"
}

variable "default_tags" {
  description = "List of tags automatically applied to every VM"
  type        = list(string)
  default     = ["lab4", "ansible"]
}

variable "enable_qemu_agent" {
  description = "Enable the QEMU guest agent inside provisioned VMs"
  type        = bool
  default     = true
}

variable "proxmox_pool" {
  description = "Optional Proxmox resource pool name"
  type        = string
  default     = ""
}

variable "cloud_init_user" {
  description = "Default cloud-init user created on each VM"
  type        = string
  default     = "ansible"
}

variable "cloud_init_password" {
  description = "Optional password for the cloud-init user"
  type        = string
  sensitive   = true
  default     = ""
}

variable "cloud_init_ssh_public_keys" {
  description = "SSH public keys injected via cloud-init"
  type        = list(string)
  default = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMUST_REPLACE_ME_WITH_REAL_KEY lab4@local"
  ]
}

variable "cloud_init_dns_servers" {
  description = "Default DNS servers configured through cloud-init"
  type        = list(string)
  default     = []
}

variable "cloud_init_search_domain" {
  description = "Search domain appended through cloud-init (optional)"
  type        = string
  default     = ""
}

variable "vm_definitions" {
  description = "Override the default VM plan. Keys correspond to logical hostnames."
  type = map(object({
    hostname      = optional(string)
    target_node   = optional(string)
    template      = optional(string)
    cores         = number
    sockets       = optional(number, 1)
    memory        = number
    disk_gb       = number
    disk_type     = optional(string, "scsi")
    disk_storage  = optional(string)
    bridge        = optional(string)
    network_model = optional(string, "virtio")
    vlan          = optional(number)
    firewall      = optional(bool, false)
    ip_cidr       = string
    gateway       = optional(string)
    dns_servers   = optional(list(string), [])
    tags          = optional(list(string), [])
    description   = optional(string)
  }))
  default = {}
}

variable "ansible_playbook_path" {
  description = "Path to the Ansible playbook to run after VM provisioning"
  type        = string
  default     = "../ansible/main-playbook.yml"
}

variable "ansible_inventory_path" {
  description = "Path to the Ansible inventory file"
  type        = string
  default     = "../ansible/inventory/inventory.yml"
}

variable "ansible_private_key_path" {
  description = "Path to SSH private key for Ansible provisioning"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "run_ansible_after_apply" {
  description = "Whether to automatically run Ansible playbook after VM creation"
  type        = bool
  default     = false
}

