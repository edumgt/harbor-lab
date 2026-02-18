# Windows helper scripts
Harbor를 HTTPS(self-signed)로 쓰려면 Docker 엔진이 CA를 신뢰해야 합니다.
Docker Desktop은 Windows에서 설정되므로, 아래 PowerShell을 사용하면 편합니다.

> PowerShell은 관리자 권한이 필요할 수 있습니다.

## 01_install_ca.ps1
- `certs/ca.crt`를 Windows 신뢰할 수 있는 루트 인증기관에 추가(선택)
- Docker Desktop용 `~/.docker/certs.d/<host:port>/ca.crt`로 복사

실행 예:
```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\01_install_ca.ps1 -RepoPath "C:\path\to\harbor-wsl2-lab"
```
