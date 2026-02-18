# Chapter 16 — 폐쇄망 운영 검증 시나리오 (반입→Harbor→Fractos 배포 전 점검)

## 목표
Fractos 배포 직전에 “이미지/레지스트리/인증/네트워크”가 준비됐는지 점검하는 시나리오를 제공합니다.

- Harbor에 이미지가 존재하는지
- HTTPS/인증서 문제가 없는지
- Robot Account 권한이 맞는지
- (선택) NodePort 오픈 후 curl로 health 체크가 가능한지

## 실행
```bash
./run.sh
```

## 주의
- Fractos 클러스터에 직접 접근할 수 없는 환경이면, 이 챕터는 로컬 점검까지만 수행합니다.
