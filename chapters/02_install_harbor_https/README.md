# Chapter 02 — Harbor 설치 (HTTPS self-signed)

## 목표
- Harbor offline installer 다운로드(또는 반입 파일 사용)
- 자체 CA + 서버 인증서 생성 (harbor.local)
- HTTPS(8443)로 Harbor 설치/기동

## 실행
```bash
./run.sh
```

## 결과
- `./harbor/` 폴더 생성 (installer unpack)
- `./certs/` 생성 (ca.crt, harbor.local.crt/key)
- Harbor 컨테이너 기동

## 다음 챕터
- Chapter 03에서 Docker가 이 CA를 신뢰하도록 등록해야 `docker login/push/pull`이 됩니다.
