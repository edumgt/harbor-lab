\
    #!/usr/bin/env bash
    set -euo pipefail
    source "$(dirname "$0")/../../scripts/lib.sh"
    ensure_root_dir
    banner "CH16 — Pre-flight checks for Fractos deployment"

    need_cmd curl
    need_cmd jq
    need_cmd docker

    CA="certs/ca.crt"
    [[ -f "${CA}" ]] || die "Missing ${CA}. Run Chapter 02 first."

    BASE="https://${HARBOR_HOST}:${HARBOR_HTTPS_PORT}/api/v2.0"
    AUTH="admin:${HARBOR_ADMIN_PASSWORD}"

    IMG="${HARBOR_PROJECT}/${SAMPLE_IMAGE_NAME}:${SAMPLE_IMAGE_TAG}"
    REPO="${HARBOR_PROJECT}/${SAMPLE_IMAGE_NAME}"

    echo "[1] Harbor API reachable (TLS validated by CA)"
    curl -sS --cacert "${CA}" -u "${AUTH}" "${BASE}/systeminfo" | jq '{harbor_version:.harbor_version, registry_url:.registry_url}' || die "Harbor API not reachable"

    echo "[2] Ensure project exists: ${HARBOR_PROJECT}"
    proj="$(curl -sS --cacert "${CA}" -u "${AUTH}" "${BASE}/projects?name=${HARBOR_PROJECT}" | jq 'length')"
    [[ "${proj}" != "0" ]] || die "Project not found. Run Chapter 04."

    echo "[3] Check repository exists (after CH05): ${REPO}"
    # List repos in project (may be empty)
    repos="$(curl -sS --cacert "${CA}" -u "${AUTH}" "${BASE}/projects/${HARBOR_PROJECT}/repositories" | jq 'length')"
    echo " - repo_count=${repos}"
    if [[ "${repos}" == "0" ]]; then
      echo "[WARN] No repositories found. Did you run Chapter 05 to push nginx sample?"
    fi

    echo "[4] Docker login (engine must trust CA from Chapter 03 Windows step)"
    docker login "${HARBOR_REGISTRY}" -u admin -p "${HARBOR_ADMIN_PASSWORD}"

    echo "[5] Pull the sample image from Harbor (verifies registry pull path)"
    REMOTE="${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${SAMPLE_IMAGE_NAME}:${SAMPLE_IMAGE_TAG}"
    docker pull "${REMOTE}" || echo "[WARN] Pull failed (check CA trust / image pushed)"

    echo
    echo "[NEXT] Fractos UI 배포 전 체크(사람이 확인):"
    echo " - RCS 노드에서 ${HARBOR_REGISTRY} 접근 가능(DNS/방화벽)"
    echo " - 노드 런타임이 Harbor CA를 신뢰(x509 문제 방지)"
    echo " - Robot Account로 pull 인증 성공(unauthorized 방지)"
    echo " - 모델 NFS 경로/권한 준비"
    ok "CH16 done."
