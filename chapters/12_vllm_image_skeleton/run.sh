#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../scripts/lib.sh"
ensure_root_dir
banner "CH12 — vLLM image skeleton (build only)"

need_cmd docker

IMG="vllm-skeleton:0.1"
echo "[1] Build vLLM skeleton image: ${IMG}"
docker build -t "${IMG}" ./chapters/12_vllm_image_skeleton/vllm

echo
echo "[INFO] Run example (GPU machine required):"
echo "  docker run --rm --gpus all -p 8000:8000 \\"
echo "    -v /path/to/models:/models \\"
echo "    -e TENSOR_PARALLEL_SIZE=3 \\"
echo "    ${IMG}"
ok "CH12 done."
