# Chapter 18 — kind에서 Harbor(HTTPS self-signed) 이미지 pull + 배포 (Secret/CA 포함)

## 목표
로컬 kind 클러스터(단일 control-plane)가 **Harbor(HTTPS, self-signed CA)** 레지스트리에서
이미지를 pull 해서 Pod를 띄울 수 있게 구성합니다.

여기서 어려운 포인트는 2가지입니다.
1) **인증**: Harbor private 프로젝트라면 imagePullSecret 필요
2) **TLS 신뢰**: kind 노드(컨테이너) 내부가 Harbor CA를 신뢰해야 x509 오류가 안 납니다

이 챕터는 위 2가지를 **자동으로** 처리합니다.

## 전제
- Chapter 02/03: Harbor HTTPS + CA 생성/신뢰 설정이 되어 있어야 함
- Chapter 05: Harbor에 sample image push 완료 (demo/demo-nginx:1.0)
- Chapter 17: kind 클러스터가 존재(없으면 이 챕터가 생성도 시도)

## 실행
```bash
./run.sh
```

## 결과
- kind 노드 컨테이너에 `certs/ca.crt`가 주입되어 Harbor TLS를 신뢰
- `imagePullSecret` 생성
- Harbor 이미지로 Pod 배포 후 Ready 확인


## 실무 표준 버전
- 사람 계정 대신 Robot Account(pull-only)를 쓰는 **Chapter 18-robot**도 제공합니다.
