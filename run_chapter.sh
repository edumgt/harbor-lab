\
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ $# -lt 1 ]]; then
      echo "Usage: ./run_chapter.sh <chapter-number>"
      echo "Example: ./run_chapter.sh 01"
      exit 1
    fi

    CH="$1"
    DIR="chapters/${CH}_*"
    TARGET="$(ls -d ${DIR} 2>/dev/null | head -n 1 || true)"

    if [[ -z "${TARGET}" ]]; then
      echo "[ERROR] Chapter not found: ${CH}"
      echo "Available:"
      ls -1 chapters | sed 's/^/ - /'
      exit 1
    fi

    echo "[RUN] ${TARGET}/run.sh"
    bash "${TARGET}/run.sh"
