#!/usr/bin/env bash
set -euo pipefail

INTERVAL=${INTERVAL_SECONDS:-86400}
RUN_ON_START=${RUN_ON_START:-true}
PORT=${PORT:-8080}

mkdir -p /app/app/render

run_job() {
  echo "[Run] Starting backup at $(date '+%Y-%m-%d %H:%M:%S')"
  /app/backup.sh
  echo "[Run] Finished backup at $(date '+%Y-%m-%d %H:%M:%S')"
}

# รันทันทีถ้าเปิด container
if [ "$RUN_ON_START" = "true" ]; then
  run_job
fi

# วนรอบรันทุก INTERVAL
(
  while true; do
    echo "[Sleep] Waiting ${INTERVAL} seconds before next backup..."
    sleep "${INTERVAL}"
    run_job
  done
) &

# Serve ไฟล์สำหรับ render
echo "[Server] Starting HTTP server on port $PORT..."
cd /app/app/render
python3 -m http.server "$PORT"
