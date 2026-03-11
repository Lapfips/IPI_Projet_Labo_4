#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat >&2 <<'USAGE'
Usage:
    ./scripts/main.sh vault {init|edit <file>|encrypt <file>|decrypt <file>}
    ./scripts/main.sh deploy [env vars: TAGS, INVENTORY, PLAYBOOK]
    ./scripts/main.sh destroy
USAGE
    exit 1
}

cmd=${1:-}
case "$cmd" in
    vault)
        shift
        ./scripts/ansible-vault.sh "$@"
        ;;
    deploy)
        ./scripts/deploy.sh
        ;;
    destroy)
        ./scripts/destroy.sh
        ;;
    *)
        usage
        ;;
esac