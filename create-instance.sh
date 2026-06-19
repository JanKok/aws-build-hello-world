#!/usr/bin/env bash
# aws-build-hello-world/create-instance.sh — One-time setup: resolve the Ubuntu AMI, launch
# a new EC2 instance, and save its ID. Run this once before the first build.
# After this completes, use build.sh for each build session.
# To force a fresh AMI lookup, delete .state/ami-id.
set -e

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
source "$AWS_PATH/args.sh" "$@"

if [ -f "$STATE_DIR/ami-id" ]; then
  AMI_ID=$(cat "$STATE_DIR/ami-id")
  echo "Using saved AMI: $AMI_ID"
else
  echo "Fetching latest Ubuntu 22.04 AMI for $AWS_REGION..."
  AMI_ID=$(aws ec2 describe-images \
    --owners 099720109477 \
    --filters \
      'Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*' \
      'Name=state,Values=available' \
    --query 'sort_by(Images,&CreationDate)[-1].ImageId' \
    --output text \
    --region "$AWS_REGION")
  mkdir -p "$STATE_DIR"
  echo "$AMI_ID" > "$STATE_DIR/ami-id"
  echo "Resolved and saved AMI: $AMI_ID  (delete .state/ami-id to re-fetch)"
fi

"$AWS_PATH/launch.sh"

echo "=== Stopping instance after setup ==="
"$AWS_PATH/stop.sh"

echo ""
echo "Instance created. ID saved to $STATE_DIR/instance-id"
echo "Run build.sh to compile and fetch the hello binary."
