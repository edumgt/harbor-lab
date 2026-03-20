#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../scripts/lib.sh"
ensure_root_dir
banner "CH05 — Build & push/pull nginx sample to Harbor (HTTPS)"

need_cmd docker

IMG_LOCAL="${SAMPLE_IMAGE_NAME}:${SAMPLE_IMAGE_TAG}"
IMG_REMOTE="${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${SAMPLE_IMAGE_NAME}:${SAMPLE_IMAGE_TAG}"

echo "[1] Build local sample image: ${IMG_LOCAL}"
docker build -t "${IMG_LOCAL}" ./sample-nginx

echo "[2] Login to Harbor: ${HARBOR_REGISTRY}"
docker login "${HARBOR_REGISTRY}" -u admin -p "${HARBOR_ADMIN_PASSWORD}"

echo "[3] Tag -> ${IMG_REMOTE}"
docker tag "${IMG_LOCAL}" "${IMG_REMOTE}"

echo "[4] Push"
docker push "${IMG_REMOTE}"

echo "[5] Pull (simulate fresh node)"
docker pull "${IMG_REMOTE}"

echo "[6] Run container from Harbor image"
docker rm -f nginx-lab >/dev/null 2>&1 || true
docker run -d --name nginx-lab -p 18080:80 "${IMG_REMOTE}"
echo "Open: http://localhost:18080"

ok "Chapter 05 done. Stop with: docker rm -f nginx-lab"
