#!/usr/bin/env bash
set -euo pipefail

if [[ -d terraform ]]; then
  pushd terraform >/dev/null
  if command -v terraform >/dev/null 2>&1; then
    echo "[!] Terraform destroy in 5s (Ctrl+C to cancel)"
    sleep 5
    terraform destroy -auto-approve || true
  else
    echo "terraform not installed, skipping destroy"
  fi
  popd >/dev/null
fi

echo "[✓] Destroy finished (if applicable)"
