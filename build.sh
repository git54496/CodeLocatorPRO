#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT_DIR="$SCRIPT_DIR"
ADAPTER_DIR="$ROOT_DIR/adapter"
PORT="${1:-49622}"
GRAB_ID="${2:-}"

echo "Building adapter..."
(
  cd "$ADAPTER_DIR"
  ./gradlew installDist --no-daemon
)

BIN=""
for candidate in \
  "$ADAPTER_DIR/build/install/grab/bin/grab" \
  "$ADAPTER_DIR/build/install/codelocator-adapter/bin/grab" \
  "$ADAPTER_DIR/build/install/codelocator-adapter/bin/codelocator-adapter"
do
  if [[ -x "$candidate" ]]; then
    BIN="$candidate"
    break
  fi
done

if [[ -z "$BIN" ]]; then
  echo "Build finished but viewer binary is missing under $ADAPTER_DIR/build/install"
  exit 1
fi

if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  PID="$(lsof -nP -iTCP:"$PORT" -sTCP:LISTEN -t | head -n 1)"
  if [[ -n "${PID}" ]]; then
    kill "${PID}" 2>/dev/null || true
    sleep 0.3
  fi
fi

echo "Starting viewer on port ${PORT}..."
"$BIN" viewer serve --port "$PORT" &
VIEWER_PID=$!

for _ in {1..40}; do
  if curl -fsS "http://127.0.0.1:${PORT}/api/health" >/dev/null 2>&1; then
    break
  fi
  sleep 0.2
done

if [[ -n "$GRAB_ID" ]]; then
  URL="http://127.0.0.1:${PORT}/?grab_id=${GRAB_ID}"
else
  URL="http://127.0.0.1:${PORT}/"
fi

echo "Viewer PID: ${VIEWER_PID}"
echo "Viewer URL: ${URL}"
open "${URL}" >/dev/null 2>&1 || true

wait "${VIEWER_PID}"
