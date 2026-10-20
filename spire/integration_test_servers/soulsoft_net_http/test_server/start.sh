#!/usr/bin/env bash
set -e

PORT=15050
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Starting TestServer on http://127.0.0.1:${PORT} ..."
echo "Press Ctrl+C to stop."
echo

exec python3 "$SCRIPT_DIR/server.py" --host "127.0.0.1" --port "${PORT}"
