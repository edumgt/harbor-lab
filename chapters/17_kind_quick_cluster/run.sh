\
    #!/usr/bin/env bash
    set -euo pipefail
    source "$(dirname "$0")/../../scripts/lib.sh"
    ensure_root_dir
    banner "CH17 — kind quick cluster (create + smoke test)"

    need_cmd docker
    need_cmd kind
    need_cmd kubectl

    CLUSTER="${KIND_CLUSTER_NAME:-harbor-lab}"
    PORT="${KIND_SMOKE_PORT:-18082}"

    echo "[1] Create kind cluster: ${CLUSTER}"
    if kind get clusters | grep -qx "${CLUSTER}"; then
      echo " - already exists, skip"
    else
      cat > /tmp/kind-${CLUSTER}.yaml <<'EOF'
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    nodes:
      - role: control-plane
        extraPortMappings:
          - containerPort: 30080
            hostPort: 30080
            protocol: TCP
    EOF
      kind create cluster --name "${CLUSTER}" --config "/tmp/kind-${CLUSTER}.yaml"
    fi

    echo "[2] Show nodes"
    kubectl get nodes -o wide

    echo "[3] Show system pods (kube-system)"
    kubectl get pods -n kube-system -o wide

    echo "[4] Smoke test: run nginx Pod + port-forward"
    kubectl delete pod kind-nginx --ignore-not-found >/dev/null 2>&1 || true
    kubectl run kind-nginx --image=nginx:alpine --port=80 >/dev/null

    echo " - waiting for Pod ready..."
    kubectl wait --for=condition=Ready pod/kind-nginx --timeout=120s

    echo " - port-forward :${PORT} -> pod/kind-nginx:80 (Ctrl+C to stop)"
    echo "   Open in Windows browser: http://localhost:${PORT}"
    kubectl port-forward pod/kind-nginx "${PORT}:80"
