#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../scripts/lib.sh"
ensure_root_dir
banner "CH18-robot — kind pulls from Harbor using Robot Account (pull-only)"

need_cmd docker
need_cmd kind
need_cmd kubectl
need_cmd curl
need_cmd jq

CA="certs/ca.crt"
[[ -f "${CA}" ]] || die "Missing ${CA}. Run Chapter 02 first."

CLUSTER="${KIND_CLUSTER_NAME:-harbor-lab}"
NS="${KIND_NS:-harbor-lab}"
IMG="${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${SAMPLE_IMAGE_NAME}:${SAMPLE_IMAGE_TAG}"
BASE="https://${HARBOR_HOST}:${HARBOR_HTTPS_PORT}/api/v2.0"
ADMIN_AUTH="admin:${HARBOR_ADMIN_PASSWORD}"

ROBOT_NAME="${HARBOR_ROBOT_NAME:-robot-${HARBOR_PROJECT}-puller}"
ROBOT_USER=""
ROBOT_SECRET=""

echo "[0] Ensure project exists: ${HARBOR_PROJECT}"
proj_json="$(curl -sS --cacert "${CA}" -u "${ADMIN_AUTH}" "${BASE}/projects?name=${HARBOR_PROJECT}")"
proj_id="$(echo "${proj_json}" | jq -r '.[0].project_id // empty')"
[[ -n "${proj_id}" ]] || die "Project not found. Run Chapter 04 first."

echo "[1] Create Robot Account (pull-only): ${ROBOT_NAME}"
payload="$(jq -n \
  --arg name "${ROBOT_NAME}" \
  --arg proj "${HARBOR_PROJECT}" \
  '{
    name: $name,
    description: "lab robot account (pull-only) for k8s",
    duration: -1,
    level: "project",
    permissions: [
      {kind:"project", namespace:$proj, access:[{resource:"repository", action:"pull"}]}
    ]
  }')"

resp="$(curl -sS --cacert "${CA}" -u "${ADMIN_AUTH}" \
  -H "Content-Type: application/json" \
  -d "${payload}" \
  "${BASE}/robots")"

if echo "${resp}" | jq -e '.secret != null' >/dev/null 2>&1; then
  ROBOT_USER="$(echo "${resp}" | jq -r '.name')"
  ROBOT_SECRET="$(echo "${resp}" | jq -r '.secret')"
  echo
  ok "Robot created (secret is shown once). Save it:"
  echo "  ROBOT_USER=${ROBOT_USER}"
  echo "  ROBOT_SECRET=${ROBOT_SECRET}"
else
  echo
  echo "[WARN] Robot secret not returned (likely already exists)."
  echo "       Please rotate/create a new robot in Harbor UI:"
  echo "         Project -> Robot Accounts -> (New Robot or Refresh/Rotate)"
  echo "       API response:"
  echo "${resp}" | jq . || true
  echo
  echo "If you already have robot creds, export before running:"
  echo "  export HARBOR_ROBOT_USER='robot$...'"
  echo "  export HARBOR_ROBOT_SECRET='...'"
  ROBOT_USER="${HARBOR_ROBOT_USER:-}"
  ROBOT_SECRET="${HARBOR_ROBOT_SECRET:-}"
  [[ -n "${ROBOT_USER}" && -n "${ROBOT_SECRET}" ]] || die "Robot creds not available. Rotate in UI or export HARBOR_ROBOT_USER/HARBOR_ROBOT_SECRET."
fi

echo "[2] Ensure kind cluster exists: ${CLUSTER}"
if ! kind get clusters | grep -qx "${CLUSTER}"; then
  cat > /tmp/kind-${CLUSTER}.yaml <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
EOF
  kind create cluster --name "${CLUSTER}" --config "/tmp/kind-${CLUSTER}.yaml"
fi

echo "[3] Inject Harbor CA into kind node(s)"
NODES="$(kind get nodes --name "${CLUSTER}" 2>/dev/null | tr '\n' ' ')"
for node in ${NODES}; do
  echo " - node: ${node}"
  docker cp "${CA}" "${node}:/usr/local/share/ca-certificates/harbor-lab-ca.crt"
  docker exec "${node}" update-ca-certificates >/dev/null
done
ok "CA injected"

echo "[4] Create namespace + imagePullSecret using Robot Account"
kubectl get ns "${NS}" >/dev/null 2>&1 || kubectl create ns "${NS}"

kubectl -n "${NS}" delete secret harbor-cred >/dev/null 2>&1 || true
kubectl -n "${NS}" create secret docker-registry harbor-cred \
  --docker-server="${HARBOR_REGISTRY}" \
  --docker-username="${ROBOT_USER}" \
  --docker-password="${ROBOT_SECRET}" >/dev/null

echo "[5] Deploy Pod from Harbor image: ${IMG}"
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

echo "[6] Wait Ready and show"
kubectl -n "${NS}" wait --for=condition=Ready pod/nginx-from-harbor --timeout=180s
kubectl -n "${NS}" get pod nginx-from-harbor -o wide

echo
echo "[Optional] Test:"
echo "  kubectl -n ${NS} port-forward pod/nginx-from-harbor 18083:80"
echo "  Open: http://localhost:18083"
ok "CH18-robot done."
