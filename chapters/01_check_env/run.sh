\
    #!/usr/bin/env bash
    set -euo pipefail
    source "$(dirname "$0")/../../scripts/lib.sh"
    banner "CH01 — Check environment (WSL2 + Docker Desktop)"

    need_cmd docker
    docker version
    docker compose version

    echo
    echo "[INFO] Docker server info:"
    docker info | sed -n '1,120p'

    echo
    echo "[NEXT] If docker commands fail:"
    echo "- Docker Desktop 실행"
    echo "- Settings > Resources > WSL Integration > Ubuntu ON"
    ok "Environment looks good."
