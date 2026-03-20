#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../scripts/lib.sh"
ensure_root_dir
banner "CH07 — Retention policy example (optional)"

need_cmd curl
need_cmd jq

CA="certs/ca.crt"
[[ -f "${CA}" ]] || die "Missing ${CA}. Run Chapter 02 first."

BASE="https://${HARBOR_HOST}:${HARBOR_HTTPS_PORT}/api/v2.0"
AUTH="admin:${HARBOR_ADMIN_PASSWORD}"

echo "[1] Get project id: ${HARBOR_PROJECT}"
proj_json="$(curl -sS --cacert "${CA}" -u "${AUTH}" "${BASE}/projects?name=${HARBOR_PROJECT}")"
proj_id="$(echo "${proj_json}" | jq -r '.[0].project_id // empty')"
[[ -n "${proj_id}" ]] || die "Project not found. Run Chapter 04 first."
echo " - project_id=${proj_id}"

echo "[2] Create a simple retention policy: keep last 5 artifacts per repository"
# Harbor retention policy format can vary by version; this is a practical example for learning.
payload="$(jq -n --argjson pid "${proj_id}" '{
  algorithm: "or",
  rules: [{
    disabled: false,
    action: "retain",
    template: "latestPushedK",
    params: { latestPushedK: 5 },
    tag_selectors: [{ kind:"doublestar", decoration:"matches", pattern:"**" }],
    scope_selectors: { repository: [{ kind:"doublestar", decoration:"repoMatches", pattern:"**" }] }
  }],
  trigger: { kind: "Schedule", settings: { cron: "0 0 3 * * *" } },
  enabled: true,
  scope: { level: "project", ref: $pid },
  description: "Lab: keep last 5 artifacts (scheduled daily 03:00)"
}')"

resp_code="$(curl -sS -o /tmp/harbor_ret.json -w "%{http_code}" \
  --cacert "${CA}" -u "${AUTH}" \
  -H "Content-Type: application/json" \
  -d "${payload}" \
  "${BASE}/retentions")"

echo " - http_code=${resp_code}"
if [[ "${resp_code}" == "201" || "${resp_code}" == "200" ]]; then
  ok "Retention policy created."
else
  echo "[WARN] Retention policy creation might differ by Harbor version/config."
  echo "Response:"
  cat /tmp/harbor_ret.json | jq . || cat /tmp/harbor_ret.json
  echo
  echo "You can also set retention in UI: Project -> Tag Retention"
fi

ok "Chapter 07 done."
