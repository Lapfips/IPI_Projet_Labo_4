#!/usr/bin/env bash
set -euo pipefail

VAULT_PASS_FILE="ansible/.vault_pass.txt"

usage() {
  echo "Usage: $0 {init|edit <file>|encrypt <file>|decrypt <file>}" >&2
  exit 1
}

if ! command -v ansible-vault >/dev/null 2>&1; then
  echo "ansible-vault not found. Please install Ansible." >&2
  exit 127
fi

init() {
  if [[ -f "$VAULT_PASS_FILE" ]]; then
    echo "Vault password file already exists: $VAULT_PASS_FILE"
  else
    read -s -p "Enter a strong vault password: " VAULT_PASS
    echo
    read -s -p "Confirm password: " VAULT_CONFIRM
    echo
    if [[ "$VAULT_PASS" != "$VAULT_CONFIRM" ]]; then
      echo "Passwords do not match" >&2
      exit 2
    fi
    mkdir -p "$(dirname "$VAULT_PASS_FILE")"
    printf "%s\n" "$VAULT_PASS" > "$VAULT_PASS_FILE"
    chmod 600 "$VAULT_PASS_FILE"
    echo "Created $VAULT_PASS_FILE (ignored by .gitignore)"
  fi
}

cmd=${1:-}
case "$cmd" in
  init)
    init
    ;;
  edit)
    file=${2:-}
    [[ -z "$file" ]] && usage
    ANSIBLE_VAULT_PASSWORD_FILE="$VAULT_PASS_FILE" ansible-vault edit "$file"
    ;;
  encrypt)
    file=${2:-}
    [[ -z "$file" ]] && usage
    if [[ ! -f "$file" ]]; then
      echo "File not found: $file" >&2
      exit 2
    fi
    ANSIBLE_VAULT_PASSWORD_FILE="$VAULT_PASS_FILE" ansible-vault encrypt "$file"
    ;;
  decrypt)
    file=${2:-}
    [[ -z "$file" ]] && usage
    ANSIBLE_VAULT_PASSWORD_FILE="$VAULT_PASS_FILE" ansible-vault decrypt "$file"
    ;;
  *)
    usage
    ;;
esac
