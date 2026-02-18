\
    #!/usr/bin/env bash
    set -euo pipefail
    source "$(dirname "$0")/../../scripts/lib.sh"
    ensure_root_dir
    banner "CH03 — hosts + CA trust chain (Docker Desktop)"

    # 1) WSL hosts
    if ! grep -qE '^\s*127\.0\.0\.1\s+harbor\.local\s*$' /etc/hosts; then
      echo "[1] Add harbor.local to /etc/hosts (WSL)"
      echo "127.0.0.1 harbor.local" | sudo tee -a /etc/hosts >/dev/null
      ok "Added to /etc/hosts"
    else
      ok "/etc/hosts already contains harbor.local"
    fi

    # 2) Show Windows steps
    echo
    echo "[2] Windows hosts file (manual):"
    echo "  Add: 127.0.0.1 harbor.local"
    echo "  File: C:\\Windows\\System32\\drivers\\etc\\hosts"
    echo
    echo "[3] Docker Desktop CA trust (manual or PowerShell):"
    echo "  Copy: $(pwd)/certs/ca.crt"
    echo "    -> C:\\Users\\<YOU>\\.docker\\certs.d\\${HARBOR_HOST}:${HARBOR_HTTPS_PORT}\\ca.crt"
    echo "  Then restart Docker Desktop."
    echo
    echo "  PowerShell helper:"
    echo "    windows\\01_install_ca.ps1 -RepoPath \"$(pwd)\" -HostPort \"${HARBOR_HOST}:${HARBOR_HTTPS_PORT}\""
    echo
    ok "WSL hosts done. Complete Windows steps, then proceed to Chapter 04/05."
