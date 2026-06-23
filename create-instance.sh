#!/usr/bin/env bash
# aws-build-hello-world/create-instance.sh — One-time setup: resolve the Ubuntu AMI, launch
# a new EC2 instance, and save its ID. Run this once before the first build.
# After this completes, use build.sh for each build session.
# To force a fresh AMI lookup, delete .state/ami-id.
set -e

AWS_BUILD_CONFIG="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$AWS_BUILD_CONFIG/config.sh"
source "$AWS_BUILD_UTILS/args.sh" "$@"

# Get the AMI (Amazon Machine Image) ID to use for the EC2 instance. This is the
# image that will be used to create the instance, and it should have the
# necessary environment and dependencies for the build process. The
# get-ami-id.sh script contains logic to either use a hardcoded AMI ID, reuse a
# previously saved AMI ID, or fetch the latest suitable AMI from AWS based on
# specified criteria. After this script runs, the AMI_ID variable will be set
# and ready to use for launching the instance.
source "$AWS_BUILD_CONFIG/get-ami-id.sh"

echo "=== Launching instance with AMI: $AMI_ID ==="
"$AWS_BUILD_UTILS/launch.sh"

echo "=== Stopping instance after setup ==="
"$AWS_BUILD_UTILS/stop.sh"

echo ""
echo "Instance created. ID saved to $STATE_DIR/instance-id"
echo "Run build.sh to compile and fetch the hello binary."
