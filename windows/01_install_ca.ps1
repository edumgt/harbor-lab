\
    param(
      [Parameter(Mandatory=$true)]
      [string]$RepoPath,

      [string]$HostPort = "harbor.local:8443",

      [switch]$InstallToWindowsRootStore
    )

    $ErrorActionPreference = "Stop"

    $caPath = Join-Path $RepoPath "certs\ca.crt"
    if (!(Test-Path $caPath)) {
      throw "ca.crt not found: $caPath (Run Chapter 02 to generate certs first)"
    }

    # 1) Docker Desktop trust (recommended)
    $dockerCertDir = Join-Path $env:USERPROFILE ".docker\certs.d\$HostPort"
    New-Item -ItemType Directory -Force -Path $dockerCertDir | Out-Null
    Copy-Item -Force $caPath (Join-Path $dockerCertDir "ca.crt")
    Write-Host "[OK] Copied CA to Docker certs.d: $dockerCertDir\ca.crt"

    # 2) Optional: Windows trusted root store (for browser)
    if ($InstallToWindowsRootStore) {
      $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($caPath)
      $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root","LocalMachine")
      $store.Open("ReadWrite")
      $store.Add($cert)
      $store.Close()
      Write-Host "[OK] Installed CA to Windows Root store (LocalMachine\Root)"
    } else {
      Write-Host "[INFO] Skipped Windows Root store install. Use -InstallToWindowsRootStore to enable."
    }

    Write-Host
    Write-Host "Next: Restart Docker Desktop for changes to take effect."
