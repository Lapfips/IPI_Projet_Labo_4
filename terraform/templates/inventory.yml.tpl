# Auto-generated Ansible inventory from Terraform
# DO NOT EDIT MANUALLY - managed by Terraform

all:
  children:
%{ for group in distinct(flatten([for vm in vms : split(";", vm.groups)])) ~}
%{ if group != "lab4" && group != "ansible" ~}
    ${group}_servers:
      hosts:
%{ for key, vm in vms ~}
%{ if contains(split(";", vm.groups), group) ~}
        ${replace(vm.ip, "ip=", "")}:
          ansible_host: ${replace(vm.ip, "ip=", "")}
          hostname: ${vm.hostname}
%{ endif ~}
%{ endfor ~}
%{ endif ~}
%{ endfor ~}
  vars:
    ansible_user: ansible
    ansible_become: true
    ansible_become_method: sudo
