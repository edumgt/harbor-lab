#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../scripts/lib.sh"
ensure_root_dir
banner "CH10 — Cleanup"

echo "[1] Stop nginx sample containers"
docker rm -f nginx-lab nginx-airgap >/dev/null 2>&1 || true

echo "[2] Stop Harbor"
if [[ -d harbor ]]; then
  pushd harbor >/dev/null
  docker compose down || true
  popd >/dev/null
  ok "Harbor down"
else
  echo " - harbor dir not found, skip"
fi

echo
echo "[OPTIONAL] Remove lab artifacts:"
echo " - rm -rf harbor certs harbor/data *.tar.gz airgap_nginx_alpine.tar"
ok "Chapter 10 done."
