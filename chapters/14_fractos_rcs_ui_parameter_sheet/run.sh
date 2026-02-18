\
    #!/usr/bin/env bash
    set -euo pipefail
    source "$(dirname "$0")/../../scripts/lib.sh"
    ensure_root_dir
    banner "CH14 — Generate Fractos RCS UI parameter sheet"

    OUT_DIR="artifacts"
    mkdir -p "${OUT_DIR}"

    # Defaults for vLLM service exposure
    APP_PORT="${APP_PORT:-8000}"
    NODEPORT="${NODEPORT:-30080}"
    HEALTH_PATH="${HEALTH_PATH:-/health}"

    # Model mount info placeholders
    MODEL_MOUNT_PATH="${MODEL_MOUNT_PATH:-/models}"
    NFS_SERVER="${NFS_SERVER:-<NFS_SERVER_IP>}"
    NFS_EXPORT_PATH="${NFS_EXPORT_PATH:-/exports/models/gpt-oss-120b}"

    # vLLM tuning placeholders
    TP="${TENSOR_PARALLEL_SIZE:-3}"
    GMU="${GPU_MEMORY_UTILIZATION:-0.90}"
    MAXLEN="${MAX_MODEL_LEN:-4096}"

    # Image suggestion (use your real pushed image)
    VLLM_IMAGE="${VLLM_IMAGE:-${HARBOR_REGISTRY}/${HARBOR_PROJECT}/vllm-skeleton:0.1}"

    cat > "${OUT_DIR}/fractos_rcs_env.list" <<EOF
MODEL_PATH=${MODEL_MOUNT_PATH}
SERVE_HOST=0.0.0.0
SERVE_PORT=${APP_PORT}
TENSOR_PARALLEL_SIZE=${TP}
GPU_MEMORY_UTILIZATION=${GMU}
MAX_MODEL_LEN=${MAXLEN}
EOF

    cat > "${OUT_DIR}/fractos_rcs_ports.md" <<EOF
# Ports / HealthCheck / Exposure

- Container Port: ${APP_PORT}
- Health path (for readiness/liveness): ${HEALTH_PATH}
- NodePort (if using NodePort): ${NODEPORT}

Notes:
- If Fractos UI provides "Service Exposure" options, map to:
  - targetPort: ${APP_PORT}
  - nodePort: ${NODEPORT} (only if you must fix it)
- In many clusters, NodePort range is 30000-32767.
EOF

    cat > "${OUT_DIR}/fractos_rcs_params.md" <<EOF
# Fractos RCS UI 입력값 시트 (복사/참조용)

## 1) Container Image
- Image: **${VLLM_IMAGE}**
- Registry: **${HARBOR_REGISTRY}**
- Project: **${HARBOR_PROJECT}**

> 권장: Harbor에서 **Robot Account**를 만들어 pull 권한만 주고, RCS에 그 자격증명을 등록하세요(사람 계정 지양).

## 2) Command / Args
- (권장) Image ENTRYPOINT 사용: **Yes**
- (직접 지정 필요 시) Command: *(비움)*
- Args: *(비움)*
  - vLLM 이미지는 환경변수로 파라미터를 받게 설계하는 것이 UI 폼에서 관리하기 쉽습니다.

## 3) Environment Variables (ENV)
아래 내용을 RCS UI의 ENV 입력란에 그대로 넣으세요:

\`\`\`
$(cat "${OUT_DIR}/fractos_rcs_env.list")
\`\`\`

## 4) GPU / Resource
- GPU Count: **3**  (L40S 기준 TP=3 가정)
- CPU/Memory: 워크로드에 맞게(예: 요청 4 vCPU / 16Gi 이상 권장)

> TP(텐서 병렬) 값은 **TENSOR_PARALLEL_SIZE=${TP}**와 GPU 개수가 반드시 일치해야 합니다.

## 5) Volume / Model Mount (권장: 모델은 이미지에 넣지 말고 마운트)
- Mount Path in container: **${MODEL_MOUNT_PATH}**
- NFS Server: **${NFS_SERVER}**
- NFS Export Path: **${NFS_EXPORT_PATH}**

## 6) Network Exposure
- Container Port: **${APP_PORT}**
- (선택) NodePort: **${NODEPORT}**
- Health Check Path: **${HEALTH_PATH}**

## 7) Harbor 인증서(HTTPS self-signed) 관련
- RCS 노드/런타임이 Harbor CA를 신뢰해야 pull이 됩니다.
- 사내는 보통 “사내 CA 배포”로 해결하며, 랩에서는 Chapter 03의 CA 등록 절차를 참고하세요.

EOF

    echo
    ok "Artifacts created:"
    echo " - ${OUT_DIR}/fractos_rcs_params.md"
    echo " - ${OUT_DIR}/fractos_rcs_env.list"
    echo " - ${OUT_DIR}/fractos_rcs_ports.md"
