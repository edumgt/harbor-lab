# Airgap notes (폐쇄망 운영 메모)

## 핵심 원칙
- 내부(폐쇄망)에서는 **외부 레지스트리 접근을 금지**하고, Harbor만 바라본다.
- 외부망에서 빌드/다운로드(apt/pip/base image pull)를 끝내고, **이미지 tar로 반입**한다.
- 내부에선 `docker load` → `docker push Harbor` → K8s/Fractos가 Harbor에서 pull

## 모델 파일(대형) 권장 패턴
- 이미지에는 vLLM 런타임만 포함
- 모델 가중치는 NFS/오브젝트스토리지에 저장
- Pod는 /models로 마운트해서 실행 (업데이트/교체/캐시 관리가 쉬움)
