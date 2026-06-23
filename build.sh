#!/usr/bin/env bash
# aws-build-hello-world/build.sh — Full build pipeline: start EC2, sync hello.c, compile with
# gcc, fetch the binary to hello-world-example/bin/, stop EC2. Can be run from any directory.
set -e

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
source "$AWS_BUILD_UTILS/args.sh" "$@"

"$AWS_BUILD_UTILS/start.sh"

INSTANCE_IP=$(cat "$STATE_DIR/instance-ip")

"$AWS_BUILD_UTILS/dry-run-check.sh" || exit 0

echo "=== Syncing source to EC2 ==="
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$REMOTE_USER@$INSTANCE_IP" \
  "mkdir -p $REMOTE_SRC"
# -a  archive mode: preserves permissions, timestamps, symlinks, etc.
# -v  verbose: print each file as it is transferred
# -z  compress data during transfer to reduce bandwidth
# -e  specify the remote shell to use (ssh with key and no host key check)
# "$LOCAL_SRC/"  trailing slash means sync the *contents* of the directory, not the directory itself
# "$REMOTE_USER@$INSTANCE_IP:$REMOTE_SRC/"  destination on the EC2 instance
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
"$AWS_BUILD_UTILS/stop.sh"

echo "=== Build complete. Binary is at $LOCAL_BIN/hello ==="
