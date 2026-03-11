#!/usr/bin/env bash
printf "\nEnsuring shell files integrity...\n"
for file in $(find . -name "*.sh"); do bash -n $file && printf "    [OK] $file\n" || printf "    [FAILED] $file\n"; done

printf "\nEnsuring Ansible playbooks files syntax...\n"
for file in $(find ansible -name "*playbook*.yml" -or -name "*playbook*.yaml"); do ansible-lint $file && printf "    [OK] $file\n" || printf "    [FAILED] $file\n"; done

printf "\nEnsuring Ansible playbooks integrity...\n"
for file in $(find ansible -name "*playbook*.yml" -or -name "*playbook*.yaml"); do ansible-playbook --syntax-check $file && printf "    [OK] $file\n" || printf "    [FAILED] $file\n"; done