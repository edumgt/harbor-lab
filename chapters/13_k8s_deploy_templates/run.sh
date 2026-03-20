#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../scripts/lib.sh"
ensure_root_dir
banner "CH13 — K8s deploy templates (structure learning)"

echo "[INFO] This chapter provides manifests and helper script."
echo
echo "Files:"
echo " - chapters/13_k8s_deploy_templates/manifests/00_namespace.yaml"
echo " - chapters/13_k8s_deploy_templates/manifests/10_imagepullsecret.sh"
echo " - chapters/13_k8s_deploy_templates/manifests/20_deploy_vllm.yaml"
echo " - chapters/13_k8s_deploy_templates/manifests/30_service_nodeport.yaml"
echo
echo "Apply example:"
echo "  kubectl apply -f chapters/13_k8s_deploy_templates/manifests/00_namespace.yaml"
echo "  bash chapters/13_k8s_deploy_templates/manifests/10_imagepullsecret.sh llm-infer ${HARBOR_REGISTRY} admin ${HARBOR_ADMIN_PASSWORD}"
echo "  kubectl apply -f chapters/13_k8s_deploy_templates/manifests/20_deploy_vllm.yaml"
echo "  kubectl apply -f chapters/13_k8s_deploy_templates/manifests/30_service_nodeport.yaml"
echo
echo "Check:"
echo "  kubectl -n llm-infer get pod,svc"
ok "CH13 guide printed."
