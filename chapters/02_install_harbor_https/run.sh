\
    #!/usr/bin/env bash
    set -euo pipefail
    source "$(dirname "$0")/../../scripts/lib.sh"
    ensure_root_dir
    banner "CH02 — Install Harbor (HTTPS self-signed) on WSL2"

    need_cmd curl
    need_cmd tar
    need_cmd openssl
    need_cmd docker

    TGZ="harbor-offline-installer-${HARBOR_VERSION#v}.tgz"
    URL="https://github.com/goharbor/harbor/releases/download/${HARBOR_VERSION}/${TGZ}"

    echo "[1/5] Get Harbor offline installer: ${TGZ}"
    if [[ ! -f "${TGZ}" ]]; then
      echo " - downloading: ${URL}"
      curl -L -o "${TGZ}" "${URL}"
    else
      echo " - already exists, skip download"
    fi

    echo "[2/5] Extract installer -> ./harbor"
    rm -rf harbor
    tar -xzf "${TGZ}"
    [[ -d harbor ]] || die "harbor dir not found after extraction"

    echo "[3/5] Generate CA + server certs -> ./certs"
    mkdir -p certs
    pushd certs >/dev/null
    if [[ ! -f ca.crt || ! -f ca.key ]]; then
      openssl genrsa -out ca.key 4096
      openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 \
        -subj "/C=KR/ST=Seoul/L=Seoul/O=HarborLab/OU=CA/CN=HarborLab-RootCA" \
        -out ca.crt
    else
      echo " - CA already exists, skip"
    fi

    if [[ ! -f harbor.local.key || ! -f harbor.local.crt ]]; then
      openssl genrsa -out harbor.local.key 4096
      cat > san.cnf <<'EOF'
    [ req ]
    default_bits       = 4096
    prompt             = no
    default_md         = sha256
    req_extensions     = req_ext
    distinguished_name = dn

    [ dn ]
    C=KR
    ST=Seoul
    L=Seoul
    O=HarborLab
    OU=Server
    CN=harbor.local

    [ req_ext ]
    subjectAltName = @alt_names

    [ alt_names ]
    DNS.1 = harbor.local
    DNS.2 = localhost
    IP.1  = 127.0.0.1
    EOF

      openssl req -new -key harbor.local.key -out harbor.local.csr -config san.cnf

      cat > v3.ext <<'EOF'
    authorityKeyIdentifier=keyid,issuer
    basicConstraints=CA:FALSE
    keyUsage = digitalSignature, keyEncipherment
    extendedKeyUsage = serverAuth
    subjectAltName = @alt_names

    [alt_names]
    DNS.1 = harbor.local
    DNS.2 = localhost
    IP.1  = 127.0.0.1
    EOF

      openssl x509 -req -in harbor.local.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
        -out harbor.local.crt -days 825 -sha256 -extfile v3.ext
    else
      echo " - server cert already exists, skip"
    fi
    popd >/dev/null

    echo "[4/5] Prepare harbor.yml (HTTPS 8443) + copy certs"
    cp -f harbor-config/harbor.yml.https.tmpl harbor/harbor.yml

    # Update passwords in harbor.yml from .env
    sed -i "s/^harbor_admin_password:.*/harbor_admin_password: ${HARBOR_ADMIN_PASSWORD}/" harbor/harbor.yml
    sed -i "s/^  password:.*/  password: ${HARBOR_DB_PASSWORD}/" harbor/harbor.yml

    mkdir -p harbor/ssl
    cp -f certs/harbor.local.crt harbor/ssl/harbor.local.crt
    cp -f certs/harbor.local.key harbor/ssl/harbor.local.key

    echo "[5/5] Install & start Harbor"
    pushd harbor >/dev/null
    ./install.sh
    popd >/dev/null

    echo
    ok "Harbor should be running."
    echo " - HTTPS UI: $(harbor_ui_https)"
    echo " - HTTP  UI:  $(harbor_ui_http)  (optional)"
    echo
    echo "[NEXT] Chapter 03: register CA trust for Docker Desktop (required for docker login/push)."
