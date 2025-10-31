#!/usr/bin/env bash
set -euo pipefail

INTERVAL=${INTERVAL_SECONDS:-86400}
RUN_ON_START=${RUN_ON_START:-true}
PORT=${PORT:-8080}
USERNAME=${AUTH_USERNAME:-admin}
PASSWORD=${AUTH_PASSWORD:-1234}

mkdir -p /app/app/render

run_job() {
  echo "[Run] Starting backup at $(date '+%Y-%m-%d %H:%M:%S')"
  /app/backup.sh
  echo "[Run] Finished backup at $(date '+%Y-%m-%d %H:%M:%S')"
}

# รันทันที
if [ "$RUN_ON_START" = "true" ]; then
  run_job
fi

# วนรอบทุก INTERVAL
(
  while true; do
    echo "[Sleep] Waiting ${INTERVAL} seconds before next backup..."
    sleep "${INTERVAL}"
    run_job
  done
) &

# Serve ด้วย Basic Auth
echo "[Server] Starting HTTP server on port $PORT with Basic Auth..."

cd /app/app/render

# Python mini server + Basic Auth
python3 - <<EOF
import os
from http.server import SimpleHTTPRequestHandler, HTTPServer
import base64

PORT = int(os.environ.get('PORT', 8080))
USERNAME = os.environ.get('AUTH_USERNAME', 'admin')
PASSWORD = os.environ.get('AUTH_PASSWORD', '1234')

class AuthHandler(SimpleHTTPRequestHandler):
    def do_HEAD(self):
        self.send_response(200)
        self.send_header('Content-type','text/html')
        self.end_headers()

    def do_AUTHHEAD(self):
        self.send_response(401)
        self.send_header('WWW-Authenticate', 'Basic realm="Protected"')
        self.send_header('Content-type', 'text/html')
        self.end_headers()

    def do_GET(self):
        key = self.headers.get('Authorization')
        expected = 'Basic ' + base64.b64encode(f"{USERNAME}:{PASSWORD}".encode()).decode()
        if key == expected:
            super().do_GET()
        else:
            self.do_AUTHHEAD()
            self.wfile.write(b'Unauthorized')

    def do_POST(self):
        self.do_GET()

httpd = HTTPServer(('', PORT), AuthHandler)
print(f"Serving on port {PORT} with Basic Auth")
httpd.serve_forever()
EOF
