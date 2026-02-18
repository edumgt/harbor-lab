# Fractos RCS UI 필드 매핑 치트시트 (Harbor + vLLM)

아래는 “일반적인” UI 폼 항목 기준입니다. 실제 화면 항목명은 버전에 따라 다를 수 있습니다.

## Image
- Image: `harbor.local:8443/demo/vllm-skeleton:0.1`

## Registry Credentials
- 권장: Harbor Robot Account
- Username: `robot$...`
- Password/Token: (생성 시 1회 노출되는 secret)

## GPU/Resources
- GPU count: 3 (TP=3과 일치)
- CPU/Memory: 워크로드에 맞게

## Env
- `MODEL_PATH=/models`
- `TENSOR_PARALLEL_SIZE=3`
- `GPU_MEMORY_UTILIZATION=0.90`
- `MAX_MODEL_LEN=4096`
- `SERVE_PORT=8000`

## Volumes
- NFS -> mount `/models`
- 읽기 전용 권장

## Ports / Service Exposure
- ContainerPort: 8000
- NodePort: 30080 (필요 시)
- 또는 내부 LB/Ingress 옵션이 있으면 정책에 맞춰 선택

## Health Check
- Path: `/health`
- Delay: 모델 로딩 시간을 고려(초기 60~180초 등)
