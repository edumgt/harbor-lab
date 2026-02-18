\
    #!/usr/bin/env bash
    set -euo pipefail
    source "$(dirname "$0")/lib.sh"
    banner "Status"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | sed -n '1,220p'
