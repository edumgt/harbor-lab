#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../scripts/lib.sh"
ensure_root_dir
banner "CH15 — Generate Fractos RCS UI runbook"

OUT_DIR="artifacts"
mkdir -p "${OUT_DIR}"

APP_PORT="${APP_PORT:-8000}"
HEALTH_PATH="${HEALTH_PATH:-/health}"
TP="${TENSOR_PARALLEL_SIZE:-3}"
VLLM_IMAGE="${VLLM_IMAGE:-${HARBOR_REGISTRY}/${HARBOR_PROJECT}/vllm-skeleton:0.1}"
MODEL_MOUNT_PATH="${MODEL_MOUNT_PATH:-/models}"

cat > "${OUT_DIR}/fractos_rcs_runbook.md" <<EOF
# Fractos RCS(UI 폼) 배포 런북 — 폐쇄망 + vLLM(대형모델) 기준

## 0) 사전 전제
- 이미지가 내부 Harbor에 존재: **${HARBOR_REGISTRY}**
- Harbor는 HTTPS이며, 노드 런타임이 CA를 신뢰해야 함
- 모델 가중치는 이미지에 포함하지 않고 **NFS/스토리지에 적재 후 마운트**(권장)

---

## 1) Harbor 준비 (폐쇄망 표준)
1. 프로젝트(예: ${HARBOR_PROJECT}) 생성
2. Robot Account 생성
   - 권장 권한: pull only (배포용), push는 빌드/반입용만
3. 이미지 경로 확정:
   - **${VLLM_IMAGE}**

### 실패 시 증상
- RCS가 이미지 pull 실패(unauthorized / x509 / connection refused)

### 해결 체크
- unauthorized → Robot 계정/프로젝트 권한 확인
- x509 → 노드에 CA 신뢰 배포 여부 확인
- connection → DNS/방화벽/포트(${HARBOR_HTTPS_PORT}) 확인

---

## 2) 모델 스토리지 준비 (NFS 권장)
- Container mount path: **${MODEL_MOUNT_PATH}**
- 모델 디렉터리 내부 구조를 “버전별”로 관리 권장:
  - /exports/models/gpt-oss-120b/20260218/...
  - /exports/models/gpt-oss-120b/current -> 20260218 (심볼릭 링크)

---

## 3) Fractos RCS UI 폼 입력 순서(추천)
### (1) Image
- Image: ${VLLM_IMAGE}

### (2) GPU/Resources
- GPU Count: **3**
- ENV의 TP값과 일치: **TENSOR_PARALLEL_SIZE=${TP}**

### (3) Env
- MODEL_PATH=${MODEL_MOUNT_PATH}
- SERVE_HOST=0.0.0.0
- SERVE_PORT=${APP_PORT}
- TENSOR_PARALLEL_SIZE=${TP}
- GPU_MEMORY_UTILIZATION=0.90 (시작점)
- MAX_MODEL_LEN=4096 (시작점)

### (4) Volumes
- NFS/스토리지로 모델 마운트 설정
- 읽기 전용(RO) 권장(모델 가중치 보호)

### (5) Ports / Exposure
- Container Port: ${APP_PORT}
- NodePort/서비스 노출 방식 선택
- 내부망 정책에 맞게 접근 제어(허용 IP, 방화벽) 적용

### (6) Health Check
- readiness: ${HEALTH_PATH}
- liveness: ${HEALTH_PATH}
- 모델 로딩이 오래 걸리면 initialDelay를 넉넉히(예: 60~180s)

---

## 4) 배포 후 검증
1. 인스턴스 상태: Running/Ready
2. Health:
   - http://<node-ip>:<nodeport>${HEALTH_PATH}
3. 추론 테스트(OpenAI compatible라면):
   - POST /v1/chat/completions 등 (환경에 따라 엔드포인트 확인)

---

## 5) 튜닝(기본 가이드)
- GPU_MEMORY_UTILIZATION: 0.85~0.95 범위에서 탐색
- MAX_MODEL_LEN: 메모리/성능 트레이드오프
- TP=3은 3 GPU 환경에서 고정(불일치 시 성능/실패)

---

## 6) 장애 패턴 & 빠른 체크
- OOM: GPU_MEMORY_UTILIZATION 낮추기, MAX_MODEL_LEN 줄이기
- 느린 응답: 배치/parallel 옵션(환경별), 프롬프트 길이 제한
- Health가 계속 fail: 모델 로딩 완료 전에 readiness가 때리는지, delay 조정

EOF

ok "Created: ${OUT_DIR}/fractos_rcs_runbook.md"
