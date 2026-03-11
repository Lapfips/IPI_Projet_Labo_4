#!/usr/bin/env bash
set -euo pipefail

INVENTORY=${INVENTORY:-ansible/inventory/inventory.yml}
PLAYBOOK=${PLAYBOOK:-ansible/main-playbook.yml}
TAGS=${TAGS:-}

if ! command -v ansible-playbook >/dev/null 2>&1; then
	echo "ansible-playbook not found. Please install Ansible." >&2
	exit 127
fi

if [[ -f ansible/.vault_pass.txt ]]; then
	export ANSIBLE_VAULT_PASSWORD_FILE="ansible/.vault_pass.txt"
fi

echo "[+] Installing Ansible collections"
ansible-galaxy install -r ansible/requirements.yml || true

echo "[+] Running Ansible playbook (tags: ${TAGS:-all})"
if [[ -n "$TAGS" ]]; then
	ansible-playbook -i "$INVENTORY" "$PLAYBOOK" --tags "$TAGS"
else
	ansible-playbook -i "$INVENTORY" "$PLAYBOOK"
fi

echo "[✓] Deploy finished"