#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../../scripts/lib.sh"
ensure_root_dir
banner "CH08 — kind K8s pull test (optional)"

need_cmd kind
need_cmd kubectl
need_cmd docker

CLUSTER="harbor-lab"
CONTEXT="kind-${CLUSTER}"

echo "[1] Create kind cluster: ${CLUSTER}"
if kind get clusters | grep -qx "${CLUSTER}"; then
  echo " - already exists, skip"
else
  kind create cluster --name "${CLUSTER}"
fi

# (중요) 현재 kubeconfig에 컨텍스트가 없으면 이후 kubectl이 default로 갈 수 있으니, 한번 export로 고정
if [[ -n "${KUBECONFIG:-}" ]]; then
  kind export kubeconfig --name "${CLUSTER}" --kubeconfig "${KUBECONFIG}"
else
  kind export kubeconfig --name "${CLUSTER}"
fi

echo "[2] Create imagePullSecret for Harbor"
kubectl --context "${CONTEXT}" create namespace harbor-lab >/dev/null 2>&1 || true

kubectl --context "${CONTEXT}" -n harbor-lab delete secret harbor-cred >/dev/null 2>&1 || true

# admin 대신 로봇 계정이 있으면 로봇 계정 사용(더 실전적)
DOCKER_USER="${HARBOR_ROBOT_USER:-admin}"
DOCKER_PASS="${HARBOR_ROBOT_SECRET:-${HARBOR_ADMIN_PASSWORD}}"

kubectl --context "${CONTEXT}" -n harbor-lab create secret docker-registry harbor-cred \
  --docker-server="${HARBOR_REGISTRY}" \
  --docker-username="${DOCKER_USER}" \
  --docker-password="${DOCKER_PASS}" >/dev/null

echo "[3] Deploy a Pod using Harbor image"
IMG="${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${SAMPLE_IMAGE_NAME}:${SAMPLE_IMAGE_TAG}"

cat <<EOF | kubectl --context "${CONTEXT}" apply -f -
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
kubectl --context "${CONTEXT}" -n harbor-lab get pod nginx-from-harbor -w

ok "Chapter 08 done. Cleanup: kubectl --context ${CONTEXT} -n harbor-lab delete pod nginx-from-harbor"
