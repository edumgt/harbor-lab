# Chapter 13 — K8s 배포 템플릿 (vLLM + imagePullSecret + Probe + NodePort)

## 목표
실무에서 Harbor + K8s(Fractos 포함)로 배포할 때 필요한 핵심 자원 템플릿을 제공합니다.

- `imagePullSecret`로 Harbor Private 프로젝트 pull
- readiness/liveness probe
- NodePort로 내부망 엔드포인트 오픈
- 모델 파일은 NFS/볼륨 마운트로 제공하는 형태(권장)

## 실행
```bash
./run.sh
```

## 주의
- 로컬 PC(kind/minikube)에는 보통 GPU가 없어 실제 vLLM 실행은 안 될 수 있습니다.
- 이 챕터는 “매니페스트 구조 학습” 목적이 큽니다.
