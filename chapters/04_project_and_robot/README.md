# Chapter 04 — 프로젝트 생성 & Robot Account

## 목표
- Harbor에 프로젝트를 만들고
- Robot Account를 만들어서 “자동화용 pull/push”를 연습합니다.

## 실행
```bash
./run.sh
```

## 참고
- Harbor는 기본적으로 UI에서도 만들 수 있지만, 실무 자동화를 위해 API 기반 생성이 유용합니다.
- self-signed 인증서 환경이므로 `curl`은 `--cacert certs/ca.crt`로 TLS를 검증합니다.
