#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../scripts/lib.sh"
ensure_root_dir
banner "CH06 — Airgap simulation (save/load -> Harbor mirror)"

need_cmd docker

SRC="nginx:alpine"
TAR="airgap_nginx_alpine.tar"
DEST="${HARBOR_REGISTRY}/${HARBOR_PROJECT}/nginx:alpine"

echo "[1] (External zone) pull from Docker Hub once: ${SRC}"
docker pull "${SRC}"

echo "[2] Save to tar (simulating '반입 파일'): ${TAR}"
docker save -o "${TAR}" "${SRC}"
ls -lh "${TAR}"

echo "[3] Remove local images (simulate clean internal node)"
docker image rm -f "${SRC}" >/dev/null 2>&1 || true

echo "[4] Load from tar (simulating '반입'): ${TAR}"
docker load -i "${TAR}"

echo "[5] Login to Harbor"
docker login "${HARBOR_REGISTRY}" -u admin -p "${HARBOR_ADMIN_PASSWORD}"

echo "[6] Tag + push to Harbor: ${DEST}"
docker tag "${SRC}" "${DEST}"
docker push "${DEST}"

echo "[7] Run ONLY from Harbor image"
docker rm -f nginx-airgap >/dev/null 2>&1 || true
docker run -d --name nginx-airgap -p 18081:80 "${DEST}"
echo "Open: http://localhost:18081"

ok "Chapter 06 done. Stop: docker rm -f nginx-airgap"
