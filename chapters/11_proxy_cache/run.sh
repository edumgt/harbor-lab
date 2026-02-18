\
    #!/usr/bin/env bash
    set -euo pipefail
    source "$(dirname "$0")/../../scripts/lib.sh"
    ensure_root_dir
    banner "CH11 — Proxy Cache (UI guided lab)"

    echo "[INFO] This chapter is UI-guided (Harbor proxy cache project)."
    echo
    echo "1) Open Harbor UI (HTTPS): $(harbor_ui_https)"
    echo "2) Create a new project as 'Proxy Cache'"
    echo "   - Example project name: proxy-dockerhub"
    echo "   - Upstream: Docker Hub"
    echo "3) Pull through Harbor (example):"
    echo "   docker pull ${HARBOR_HOST}:${HARBOR_HTTPS_PORT}/proxy-dockerhub/library/nginx:alpine"
    echo
    echo "[NOTE] Docker Hub rate limit may apply. You can also proxy a different upstream registry."
    ok "CH11 guide printed."
