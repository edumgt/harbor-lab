# Chapter 12 — vLLM 추론 서버 이미지 스켈레톤 (대형 모델 운영 베이스)

## 목표
“폐쇄망 반입용” 관점에서 vLLM 서버 이미지를 어떻게 구성하는지 **스켈레톤**을 제공합니다.

이 챕터는 PC에 GPU가 없어도:
- Dockerfile 구조(런타임 의존성)
- 모델 파일을 “이미지에 넣지 않고” 볼륨/NFS로 마운트하는 설계
- 엔트리포인트/환경변수/파라미터 설계
를 학습할 수 있도록 합니다.

## 실행
```bash
./run.sh
```

## 파일
- `vllm/Dockerfile` : CUDA 기반 + vLLM 설치 예시
- `vllm/entrypoint.sh` : vLLM 서버 기동 예시(환경변수로 파라미터 주입)

## 주의
- 실제 실행은 NVIDIA GPU + nvidia-container-toolkit 등이 필요합니다.
- 이 repo는 “학습/템플릿” 목적이며, 회사 표준 베이스 이미지/보안 정책에 맞게 수정하세요.
