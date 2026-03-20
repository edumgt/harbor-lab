#!/usr/bin/env bash
set -euo pipefail

# Load .env if present
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "${ROOT_DIR}/.env" ]]; then
  # shellcheck disable=SC1091
  source "${ROOT_DIR}/.env"
fi

# Defaults (override in .env)
HARBOR_HOST="${HARBOR_HOST:-harbor.local}"
HARBOR_HTTP_PORT="${HARBOR_HTTP_PORT:-8080}"
HARBOR_HTTPS_PORT="${HARBOR_HTTPS_PORT:-8443}"
HARBOR_ADMIN_PASSWORD="${HARBOR_ADMIN_PASSWORD:-Harbor12345}"
HARBOR_DB_PASSWORD="${HARBOR_DB_PASSWORD:-root123}"
HARBOR_VERSION="${HARBOR_VERSION:-v2.10.2}"
HARBOR_REGISTRY="${HARBOR_REGISTRY:-${HARBOR_HOST}:${HARBOR_HTTPS_PORT}}"
HARBOR_PROJECT="${HARBOR_PROJECT:-demo}"
SAMPLE_IMAGE_NAME="${SAMPLE_IMAGE_NAME:-demo-nginx}"
SAMPLE_IMAGE_TAG="${SAMPLE_IMAGE_TAG:-1.0}"

banner() {
  echo
  echo "================================================================================"
  printf "%s\n" "$1"
  echo "================================================================================"
}

need_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[ERROR] Missing command: $cmd"
    exit 1
  fi
}

ensure_root_dir() {
  cd "${ROOT_DIR}"
}

harbor_ui_https() {
  echo "https://${HARBOR_HOST}:${HARBOR_HTTPS_PORT}"
}

harbor_ui_http() {
  echo "http://${HARBOR_HOST}:${HARBOR_HTTP_PORT}"
}

die() { echo "[ERROR] $*"; exit 1; }
ok() { echo "[OK] $*"; }
