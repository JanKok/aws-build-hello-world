#!/usr/bin/env bash
# aws-build-hello-world/create-instance.sh — One-time setup: resolve the Ubuntu AMI, launch
# a new EC2 instance, and save its ID. Run this once before the first build.
# After this completes, use build.sh for each build session.
# To force a fresh AMI lookup, delete .state/ami-id.
set -e

# This section attempts to automate the task of finding a suitable AMI (Amazon
# Machine Image) for the remote build environment... at the cost of some added complexity.
# If your project has specific AMI requirements, you may want to hardcode the AMI ID
# in config.sh instead of using this lookup logic.
# TODO: Test what happens for the case where no AMI is found or the AWS CLI command fails.
# TODO: Maybe find a cleaner way to do this?
# Further guidance on AMI selection:
# In order to insure that the build environment is consistent and reproducible, it is recommended to
# use a specific AMI ID rather than relying on the latest available image. This can be achieved by
# hardcoding the AMI ID in the config.sh file or by using a versioned AMI (as shown below)that is
# known to work with your build process.
# Further guidance on AMI selection can be found here: https://cloud-images.ubuntu.com/locator/ec2/
if [ -n "$AMI_ID" ]; then
  echo "Using hardcoded AMI: $AMI_ID"
else if [ -f "$STATE_DIR/ami-id" ]; then
  # If the AMI ID has already been resolved and saved in a previous run, reuse it
  # to avoid unnecessary AWS API calls and ensure consistency across runs.
  AMI_ID=$(cat "$STATE_DIR/ami-id")
  echo "Using saved AMI: $AMI_ID"
else
  # Choose whether you want a specific version of the AMI or the latest one:
  #
  echo "Fetching specific version of Ubuntu 22.04 AMI for $AWS_REGION known to work for this project..."
  AMI_NAME_FILTER="ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-1234"
  #
  # echo "Fetching latest Ubuntu 22.04 AMI for $AWS_REGION..."
  # AMI_NAME_FILTER="ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
  #
  # echo "Fetching latest Ubuntu AMI for $AWS_REGION..."
  # AMI_NAME_FILTER="ubuntu/images/*/ubuntu-*-amd64-server-*"
  # One caveat: this will also match non-LTS releases (e.g. 25.04). If you want
  # only LTS, there's no clean filter for that — the common workaround is to
  # filter on a known LTS codename list or just pin to a specific version when
  # you need stability. Also note amd64 stays hardcoded — that should match your
  # instance type. If you switch to an ARM instance (e.g. Graviton), you'd
  # change it to arm64.
  #
  AMI_OWNER="099720109477" # Canonical's AWS account ID, which publishes official Ubuntu AMIs
  AMI_ID=$(aws ec2 describe-images \
    --owners "$AMI_OWNER" \
    --filters \
      "Name=name,Values=$AMI_NAME_FILTER" \
      'Name=state,Values=available' \
    --query 'sort_by(Images,&CreationDate)[-1].ImageId' \
    --output text \
    --region "$AWS_REGION")
  mkdir -p "$STATE_DIR"
  echo "$AMI_ID" > "$STATE_DIR/ami-id"
  echo "Resolved and saved AMI: $AMI_ID  (delete .state/ami-id to re-fetch)"
fi