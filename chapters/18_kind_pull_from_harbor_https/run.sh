#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../scripts/lib.sh"
ensure_root_dir
banner "CH18 — kind pulls image from Harbor (HTTPS self-signed)"

need_cmd docker
need_cmd kind
need_cmd kubectl

CA="certs/ca.crt"
[[ -f "${CA}" ]] || die "Missing ${CA}. Run Chapter 02 first."

CLUSTER="${KIND_CLUSTER_NAME:-harbor-lab}"
NS="${KIND_NS:-harbor-lab}"
IMG="${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${SAMPLE_IMAGE_NAME}:${SAMPLE_IMAGE_TAG}"

echo "[0] Ensure kind cluster exists: ${CLUSTER}"
if ! kind get clusters | grep -qx "${CLUSTER}"; then
  echo " - cluster not found, creating (same as CH17)"
  cat > /tmp/kind-${CLUSTER}.yaml <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
EOF
  kind create cluster --name "${CLUSTER}" --config "/tmp/kind-${CLUSTER}.yaml"
fi

echo "[1] Inject Harbor CA into kind node(s)"
# kind nodes are docker containers named like: kind-control-plane or <cluster>-control-plane
NODES="$(docker ps --format '{{.Names}}' | grep -E "^${CLUSTER}-control-plane$|^kind-control-plane$" || true)"
if [[ -z "${NODES}" ]]; then
  # fallback: query via kind
  NODES="$(kind get nodes --name "${CLUSTER}" 2>/dev/null | tr '\n' ' ')"
fi

for node in ${NODES}; do
  echo " - node: ${node}"
  docker cp "${CA}" "${node}:/usr/local/share/ca-certificates/harbor-lab-ca.crt"
  docker exec "${node}" update-ca-certificates >/dev/null
done
ok "CA injected into kind nodes"

echo "[2] Create namespace + imagePullSecret (admin creds for lab)"
kubectl get ns "${NS}" >/dev/null 2>&1 || kubectl create ns "${NS}"

kubectl -n "${NS}" delete secret harbor-cred >/dev/null 2>&1 || true
kubectl -n "${NS}" create secret docker-registry harbor-cred \
  --docker-server="${HARBOR_REGISTRY}" \
  --docker-username="admin" \
  --docker-password="${HARBOR_ADMIN_PASSWORD}" >/dev/null

echo "[3] Deploy Pod from Harbor image: ${IMG}"
kubectl -n "${NS}" delete pod nginx-from-harbor --ignore-not-found >/dev/null 2>&1 || true
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx-from-harbor
  namespace: ${NS}
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

echo "[4] Wait Ready and show"
kubectl -n "${NS}" wait --for=condition=Ready pod/nginx-from-harbor --timeout=180s
kubectl -n "${NS}" get pod nginx-from-harbor -o wide

echo
echo "[5] Optional: port-forward to test from Windows browser"
echo "  kubectl -n ${NS} port-forward pod/nginx-from-harbor 18083:80"
echo "  Open: http://localhost:18083"
ok "CH18 done."
