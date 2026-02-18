# Chapter 18-robot — Robot Account(pull-only)로 kind에서 Harbor(HTTPS) 이미지 pull + 배포

## 목표
Chapter 18은 랩 편의상 `admin`으로 imagePullSecret을 만들었습니다.
실무 표준은 **Robot Account(pull-only)**를 사용하여 배포 자격증명을 최소 권한으로 운영하는 것입니다.

이 챕터는 다음을 자동화합니다.
1) Harbor API로 Robot Account(pull-only) 생성(또는 이미 있으면 안내)
2) kind 노드에 Harbor CA 주입(HTTPS self-signed 대비)
3) K8s namespace + imagePullSecret 생성(로봇 계정)
4) Harbor 이미지로 Pod 배포 + Ready 확인

## 전제
- Harbor HTTPS 설치/기동(Chapter 02)
- CA 생성 및 신뢰 등록(Chapter 03)
- 샘플 이미지 push(Chapter 05)
- kind/kubectl 설치

## 실행
```bash
./run.sh
```

## 출력
- 로봇 계정 secret은 생성 시 1회만 출력됩니다.
  (이미 존재하는 로봇 계정이면 Harbor UI에서 rotate 해야 합니다.)
