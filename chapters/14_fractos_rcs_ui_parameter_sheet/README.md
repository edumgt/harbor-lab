# Chapter 14 — Fractos RCS UI 입력값 시트 생성 (WSL에 K8s 없어도 가능)

## 목표
Fractos(RCS)에서 **UI 폼 기반으로 GPU 컨테이너 인스턴스를 생성할 때** 필요한 값들을
`.env` 기준으로 자동 정리하여 다음 산출물을 만듭니다.

- `artifacts/fractos_rcs_params.md` : UI 입력값을 그대로 복사/참조 가능한 시트
- `artifacts/fractos_rcs_env.list` : UI의 ENV 입력란에 붙여넣기 좋은 key=value 목록
- `artifacts/fractos_rcs_ports.md` : 포트/HealthCheck/NodePort 설계 메모

## 실행
```bash
./run.sh
```

## 전제
- Harbor가 설치되어 있고(H02),
- CA 신뢰 설정이 완료되어 `docker login`이 가능한 상태(H03)면 가장 좋습니다.
- WSL에 Kubernetes가 없어도 이 챕터는 동작합니다.
