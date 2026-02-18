# Chapter 03 — hosts 설정 + Docker 신뢰 체인(CA) 등록

## 목표
- `harbor.local` 도메인이 로컬(127.0.0.1)로 해석되도록 hosts 설정
- Docker 엔진이 self-signed(정확히는 자체 CA) 인증서를 신뢰하도록 CA를 등록
  - WSL에서 docker를 쓰더라도 엔진은 Docker Desktop이므로 **Windows 쪽에 등록하는 것이 안전**

## 실행
```bash
./run.sh
```

## 해야 하는 수동 작업(중요)
1) Windows hosts:
   - `C:\Windows\System32\drivers\etc\hosts`에 아래 추가
     ```
     127.0.0.1 harbor.local
     ```
2) Docker Desktop CA 등록:
   - `certs/ca.crt`를 아래 경로에 복사
     `C:\Users\<YOU>\.docker\certs.d\harbor.local:8443\ca.crt`
   - Docker Desktop 재시작

### 더 편하게: PowerShell 사용(권장)
- `windows/01_install_ca.ps1` 참고
