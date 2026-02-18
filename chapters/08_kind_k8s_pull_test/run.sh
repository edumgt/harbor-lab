\
    #!/usr/bin/env bash
    set -euo pipefail
    source "$(dirname "$0")/../../scripts/lib.sh"
    ensure_root_dir
    banner "CH08 — kind K8s pull test (optional)"

    need_cmd kind
    need_cmd kubectl
    need_cmd docker

    CLUSTER="harbor-lab"

    echo "[1] Create kind cluster: ${CLUSTER}"
    if kind get clusters | grep -qx "${CLUSTER}"; then
      echo " - already exists, skip"
    else
      kind create cluster --name "${CLUSTER}"
    fi

    echo "[2] Create imagePullSecret for Harbor"
    kubectl create namespace harbor-lab >/dev/null 2>&1 || true

    kubectl -n harbor-lab delete secret harbor-cred >/dev/null 2>&1 || true
    kubectl -n harbor-lab create secret docker-registry harbor-cred \
      --docker-server="${HARBOR_REGISTRY}" \
      --docker-username="admin" \
      --docker-password="${HARBOR_ADMIN_PASSWORD}" >/dev/null

    echo "[3] Deploy a Pod using Harbor image"
    IMG="${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${SAMPLE_IMAGE_NAME}:${SAMPLE_IMAGE_TAG}"
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx-from-harbor
      namespace: harbor-lab
      labels:
        app: nginx-from-harbor
    spec:
      imagePullSecrets:
        - name: harbor-cred
      containers:
        - name: nginx
          image: ${IMG}
          ports:
            - containerPort: 80
    EOF

    echo "[4] Wait & show status"
    kubectl -n harbor-lab get pod nginx-from-harbor -w

    ok "Chapter 08 done. Cleanup: kubectl -n harbor-lab delete pod nginx-from-harbor"
