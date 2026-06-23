#!/usr/bin/env bash
# aws-build-hello-world/local-build.sh — Build hello.c on this machine using gcc.
set -e

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
source "$AWS_BUILD_UTILS/args.sh" "$@"

echo "=== Building hello locally ==="
echo "=== Syncing project to remote ==="
rsync-from-to "" "$LOCAL_SRC" "" "$REMOTE_SRC" "${AWS_ARG_DRY_RUN=1:+--dry-run }$RSYNC_EXTRA_OPTS"
echo "=== Project synced to remote ==="

if [ $AWS_ARG_DRY_RUN -eq 1 ]; then
  echo "=== Dry run: skipping actual build ==="
  echo "Would have done: cd $REMOTE_PROJECT_ROOT && eval $PAYLOAD_CMD"
  echo "And then:        rsync-from-to \"\" $REMOTE_BIN \"\" $LOCAL_BIN \"\""
  exit 0
fi

echo "=== Building project on remote ==="
set -x
# mkdir -p "$LOCAL_BIN"
cd "$REMOTE_PROJECT_ROOT"
eval "$PAYLOAD_CMD"
set +x

echo "=== Syncing project back to local ==="
rsync-from-to "" "$REMOTE_BIN" "" "$LOCAL_BIN" ""
echo "=== Build complete. Binary is at $LOCAL_SRC/hello ==="
