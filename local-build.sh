#!/usr/bin/env bash
# aws-build-hello-world/local-build.sh — Build hello.c on this machine using gcc.
set -e

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

echo "=== Building hello locally ==="
mkdir -p "$LOCAL_BIN"
cd "$LOCAL_SRC"
eval "$PAYLOAD_CMD"
echo "=== Build complete. Binary is at $LOCAL_SRC/hello ==="
