#!/usr/bin/env bash
# aws-build-hello-world/describe-awi.sh — Describe an AMI given its ID and region.
# Usage: describe-awi.sh ami-id region
# If ami-id is missing, use the default AMI ID from config.sh.
# If region is missing, use the default region from config.sh.
set -e

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
#source "$AWS_BUILD_UTILS/args.sh" "$@"

ami_id="${1:-$AMI_ID}"
region="${2:-$AWS_REGION}"

aws ec2 describe-images --image-ids "$ami_id" --region "$region" \
  --query 'Images[*].[ImageId,Name,State,CreationDate,OwnerId,Architecture,RootDeviceType,VirtualizationType]' \
  --output table

# --query 'Images[0].{Arch:Architecture,Virt:VirtualizationType,Name:Name,State:State}'
