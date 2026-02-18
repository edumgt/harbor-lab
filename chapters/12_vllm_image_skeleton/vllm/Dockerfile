# vLLM inference image skeleton (GPU required at runtime)
# - 폐쇄망 반입: 빌드 시 필요한 패키지 다운로드는 외부망에서 완료하고, 내부에서는 이 이미지만 사용
# - 모델 가중치는 보통 이미지에 포함하지 않고 NFS/스토리지로 마운트

FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends         python3 python3-pip python3-venv ca-certificates curl         && rm -rf /var/lib/apt/lists/*

# (권장) pip 미러/프록시를 쓰는 경우, 내부 정책에 맞게 설정
# ENV PIP_INDEX_URL=...
# ENV PIP_EXTRA_INDEX_URL=...

# vLLM + torch 설치 (버전은 GPU/드라이버/쿠다 호환에 맞게 고정 권장)
RUN python3 -m pip install --no-cache-dir -U pip         && python3 -m pip install --no-cache-dir "vllm==0.6.3" "torch==2.4.1" "transformers==4.44.2" "accelerate==0.34.2"

# 기본 실행 유저(필요 시)
WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# 모델은 보통 /models 로 마운트 (NFS/CSI 등)
ENV MODEL_PATH=/models
ENV SERVE_HOST=0.0.0.0
ENV SERVE_PORT=8000
ENV TENSOR_PARALLEL_SIZE=1
ENV GPU_MEMORY_UTILIZATION=0.90
ENV MAX_MODEL_LEN=4096

EXPOSE 8000
ENTRYPOINT ["/app/entrypoint.sh"]
