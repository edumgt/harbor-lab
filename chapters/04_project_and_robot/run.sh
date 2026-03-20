#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../scripts/lib.sh"
ensure_root_dir
banner "CH04 — Create project & robot account"

need_cmd curl
need_cmd jq

CA="certs/ca.crt"
[[ -f "${CA}" ]] || die "Missing ${CA}. Run Chapter 02 first."

BASE="https://${HARBOR_HOST}:${HARBOR_HTTPS_PORT}/api/v2.0"
AUTH="admin:${HARBOR_ADMIN_PASSWORD}"

echo "[1] Ensure project exists: ${HARBOR_PROJECT}"
# Check if project exists
code="$(curl -sS -o /tmp/harbor_proj.json -w "%{http_code}" \
  --cacert "${CA}" -u "${AUTH}" \
  "${BASE}/projects?name=${HARBOR_PROJECT}")"

if [[ "${code}" == "200" ]] && jq -e 'length>0' /tmp/harbor_proj.json >/dev/null; then
  ok "Project already exists"
else
  echo " - creating project via API"
  curl -sS --cacert "${CA}" -u "${AUTH}" \
    -H "Content-Type: application/json" \
    -d "{\"project_name\":\"${HARBOR_PROJECT}\",\"metadata\":{\"public\":\"true\"}}" \
    "${BASE}/projects" >/dev/null
  ok "Project created"
fi

echo "[2] Create robot account (push/pull) for project: ${HARBOR_PROJECT}"
ROBOT_NAME="robot-${HARBOR_PROJECT}-pusher"
payload="$(jq -n \
  --arg name "${ROBOT_NAME}" \
  --arg proj "${HARBOR_PROJECT}" \
  '{
    name: $name,
    description: "lab robot account for push/pull",
    duration: -1,
    level: "project",
    permissions: [
      {kind:"project", namespace:$proj, access:[{resource:"repository", action:"push"},{resource:"repository", action:"pull"}]}
    ]
  }')"

# Create robot
resp="$(curl -sS --cacert "${CA}" -u "${AUTH}" \
  -H "Content-Type: application/json" \
  -d "${payload}" \
  "${BASE}/robots")"

# Harbor returns token only at creation time. If already exists, it may error.
if echo "${resp}" | jq -e '.secret != null' >/dev/null 2>&1; then
  robot_user="$(echo "${resp}" | jq -r '.name')"
  robot_secret="$(echo "${resp}" | jq -r '.secret')"
  echo
  ok "Robot created. Save these credentials NOW (secret is shown once):"
  echo "  ROBOT_USER=${robot_user}"
  echo "  ROBOT_SECRET=${robot_secret}"
  echo
  echo "Tip: put them into .env as HARBOR_ROBOT_USER / HARBOR_ROBOT_SECRET (optional)."
else
  echo
  echo "[WARN] Robot creation did not return a secret. Likely already exists."
  echo "       Create/rotate from UI: Project -> Robot Accounts -> New Robot / Refresh"
  echo "       Response:"
  echo "${resp}" | jq .
fi

ok "Chapter 04 done."
