#!/usr/bin/env bash
set -euo pipefail

# NOTE:
# - 실제 운영에서는 모델 디렉터리 구조(예: /models/gpt-oss-120b)로 구체화하세요.
# - vLLM 파라미터는 GPU/모델/요구사항에 따라 튜닝이 필요합니다.

MODEL="${MODEL_PATH}"
HOST="${SERVE_HOST:-0.0.0.0}"
PORT="${SERVE_PORT:-8000}"
TP="${TENSOR_PARALLEL_SIZE:-1}"
GMU="${GPU_MEMORY_UTILIZATION:-0.90}"
MAXLEN="${MAX_MODEL_LEN:-4096}"

echo "[vLLM] MODEL=${MODEL}"
echo "[vLLM] HOST=${HOST} PORT=${PORT} TP=${TP} GMU=${GMU} MAXLEN=${MAXLEN}"

# Example command (adjust to your actual model name / format)
# - For HuggingFace: MODEL can be a local dir
# - For tensor parallel: --tensor-parallel-size
exec python3 -m vllm.entrypoints.openai.api_server       --model "${MODEL}"       --host "${HOST}"       --port "${PORT}"       --tensor-parallel-size "${TP}"       --gpu-memory-utilization "${GMU}"       --max-model-len "${MAXLEN}"
