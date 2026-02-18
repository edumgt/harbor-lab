# Chapter 07 — Retention(보존) & 태그 운영 습관

## 목표
- 실무에서 흔히 쓰는 태그/보존 원칙을 이해
- (옵션) Harbor Retention Policy를 프로젝트에 생성해 보기

## 실행
```bash
./run.sh
```

## 태그 운영 팁(실무)
- `latest` 남발 금지: 재현성/롤백 어려움
- 예: `vllm-0.6.3-cuda12.1`, `gptoss120b-20260218`, `gitsha-<short>`
- “배포 가능” 태그와 “실험” 태그를 분리
