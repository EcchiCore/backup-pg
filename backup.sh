#!/usr/bin/env bash
set -euo pipefail

RENDER_DIR="/app/app/render"
mkdir -p "$RENDER_DIR"

OUTPUT_FILE="${RENDER_DIR}/backup-$(date '+%Y%m%d-%H%M%S').txt"
echo "Backup generated at $(date)" > "$OUTPUT_FILE"

# อัพโหลดถ้ามี DESTINATION_URL
if [ -n "${DESTINATION_URL:-}" ]; then
  echo "[Upload] Uploading $OUTPUT_FILE to ${DESTINATION_URL}"
  curl -s -X POST -F "file=@${OUTPUT_FILE}" "${DESTINATION_URL}" || echo "[Warn] Upload failed"
fi

echo "[Done] Backup file ready: $OUTPUT_FILE"
