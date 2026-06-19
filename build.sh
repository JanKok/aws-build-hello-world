#!/usr/bin/env bash
# aws-build-hello-world/build.sh — Full build pipeline: start EC2, sync hello.c, compile with
# gcc, fetch the binary to hello-world-example/bin/, stop EC2. Can be run from any directory.
set -e

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
source "$AWS_PATH/args.sh" "$@"

"$AWS_PATH/start.sh"

INSTANCE_IP=$(cat "$STATE_DIR/instance-ip")

"$AWS_PATH/dry-run-check.sh" || exit 0

echo "=== Syncing source to EC2 ==="
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$REMOTE_USER@$INSTANCE_IP" \
  "mkdir -p $REMOTE_SRC"
rsync -avz \
  -e "ssh -i \"$SSH_KEY_PATH\" -o StrictHostKeyChecking=no" \
  "$LOCAL_SRC/" \
  "$REMOTE_USER@$INSTANCE_IP:$REMOTE_SRC/"

echo "=== Building on EC2 ==="
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$REMOTE_USER@$INSTANCE_IP" \
  "cd $REMOTE_SRC && $PAYLOAD_CMD"

echo "=== Fetching build artifact ==="
mkdir -p "$LOCAL_BIN"
rsync -avz \
  -e "ssh -i \"$SSH_KEY_PATH\" -o StrictHostKeyChecking=no" \
  "$REMOTE_USER@$INSTANCE_IP:$REMOTE_SRC/hello" \
  "$LOCAL_BIN/hello"

echo "=== Stopping EC2 instance ==="
"$AWS_PATH/stop.sh"

echo "=== Build complete. Binary is at $LOCAL_BIN/hello ==="
