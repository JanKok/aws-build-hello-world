#!/usr/bin/env bash
# aws-build-hello-world/deploy.sh — Run the compiled hello binary on the local machine.
# Run build.sh first to produce the binary.
set -e

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

BINARY="$LOCAL_BIN/hello"
if [ ! -f "$BINARY" ]; then
  echo "Error: binary not found at $BINARY — run build.sh first." >&2
  exit 1
fi

echo "=== Running hello locally ==="
"$BINARY"
