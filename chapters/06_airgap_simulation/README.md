# Chapter 06 — 폐쇄망 시뮬레이션: save/load/tar 반입 흐름

## 목표
“외부에서 pull → tar로 반입 → 내부 Harbor push → 이후 Harbor만 사용” 흐름을 재현합니다.

## 실행
```bash
./run.sh
```

## 동작
- 외부 이미지(nginx:alpine)를 1회 pull
- `docker save`로 tar 생성
- `docker image rm`으로 로컬에서 지운 뒤(신선한 환경 가정)
- `docker load`로 다시 반입(로드)
- Harbor로 push, 이후 Harbor pull로만 실행
