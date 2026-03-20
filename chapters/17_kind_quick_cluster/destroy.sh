#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../scripts/lib.sh"
ensure_root_dir
banner "CH17 — kind cluster destroy"

need_cmd kind
CLUSTER="${KIND_CLUSTER_NAME:-harbor-lab}"

echo "[1] Delete kind cluster: ${CLUSTER}"
kind delete cluster --name "${CLUSTER}" || true
ok "Cluster deleted."
