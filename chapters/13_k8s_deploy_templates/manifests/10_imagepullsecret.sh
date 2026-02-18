#!/usr/bin/env bash
set -euo pipefail

NS="${1:-llm-infer}"
REGISTRY="${2:-harbor.local:8443}"
USER="${3:-admin}"
PASS="${4:-Harbor12345}"

kubectl get ns "${NS}" >/dev/null 2>&1 || kubectl create ns "${NS}"

kubectl -n "${NS}" delete secret harbor-cred >/dev/null 2>&1 || true
kubectl -n "${NS}" create secret docker-registry harbor-cred       --docker-server="${REGISTRY}"       --docker-username="${USER}"       --docker-password="${PASS}"

echo "[OK] imagePullSecret created: ${NS}/harbor-cred"
