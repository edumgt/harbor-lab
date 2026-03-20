#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../scripts/lib.sh"
ensure_root_dir
banner "CH09 — Backup concept (lab) - archive data directory"

DATA_DIR="harbor/data"
[[ -d "${DATA_DIR}" ]] || die "Data dir not found: ${DATA_DIR} (Is Harbor installed/running?)"

TS="$(date +%Y%m%d_%H%M%S)"
OUT="backup_harbor_data_${TS}.tar.gz"

echo "[1] Show data size: ${DATA_DIR}"
du -sh "${DATA_DIR}" || true

echo "[2] Create archive: ${OUT}"
tar -czf "${OUT}" -C harbor data
ls -lh "${OUT}"

echo
echo "[INFO] Restore concept:"
echo " - Stop Harbor (Chapter 10 or scripts/harbor_down.sh)"
echo " - Replace harbor/data with extracted archive"
echo " - Start Harbor again"
ok "Chapter 09 done."
