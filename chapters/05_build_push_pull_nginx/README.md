# Chapter 05 — nginx 샘플 이미지: build → tag → push → pull → run

## 목표
- 로컬에서 nginx 샘플 이미지를 빌드
- Harbor에 push
- Harbor에서 pull해서 컨테이너 실행

## 실행
```bash
./run.sh
```

## 전제
- Chapter 03에서 Docker Desktop이 CA를 신뢰해야 `docker login`이 됩니다.
