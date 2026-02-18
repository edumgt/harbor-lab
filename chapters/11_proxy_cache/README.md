# Chapter 11 — Harbor Proxy Cache (실무형: 외부 레지스트리 캐시/미러)

## 목표
폐쇄망/제한망 환경에서 흔히 쓰는 패턴인 **Proxy Cache 프로젝트**를 이해합니다.

- 외부 레지스트리(Docker Hub 등)를 직접 접근하는 대신
- Harbor가 “캐시 레지스트리” 역할을 하도록 구성
- 내부 노드들은 Harbor만 바라보되, 필요한 경우 Harbor가 외부에서 가져와 캐시

## 왜 중요?
- 외부망이 완전히 막힌 환경에서는 불가하지만,
- **DMZ/제한적 egress(허용된 도메인만 접근)** 환경에서는 “표준 운영 패턴”으로 매우 자주 씁니다.
- 이미지 반입(save/load) 부담을 줄이거나, 외부 레지스트리 의존을 줄이는 데 유용합니다.

## 전제
- 이 챕터는 “개념 + UI 실습” 중심입니다.
- Docker Hub는 rate limit/인증 이슈가 있을 수 있어, 실습은 간단한 public 이미지로만 권장합니다.

## 실행
```bash
./run.sh
```

## 실습(권장 시나리오)
1) Harbor UI 접속: `https://harbor.local:8443`
2) **New Project** → 프로젝트 타입을 **Proxy Cache**로 선택
3) Upstream Registry로 `Docker Hub` 또는 테스트용 registry 지정
4) 내부에서 pull:
   - 예: `docker pull harbor.local:8443/<proxy-project>/library/nginx:alpine`
5) Harbor에서 해당 이미지가 캐시로 저장되는지 확인

## 운영 팁
- 캐시 프로젝트는 팀/서비스 단위로 분리하는 것이 권장됩니다.
- 외부망 허용 도메인/방화벽 정책과 함께 움직여야 합니다.
