#!/usr/bin/env bash
# aws-build-hello-world/config.sh — Configuration for the hello-world EC2 build project.
# Source this file at the top of every script in this project.

# Locate aws-build-utils one level up from this file: aws-build-hello-world/ → parent dir
AWS_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../aws-build-utils" && pwd)"
source "$AWS_PATH/config.sh"           # pulls in AWS_REGION and SSH_KEY_PATH

INSTANCE_TYPE="t3.micro"              # EC2 instance type; t3.micro is cheap and sufficient for gcc
INSTANCE_PRICE_PER_HOUR="0.0104"     # t3.micro on-demand price in us-east-1; verify at aws.amazon.com/ec2/pricing
# AMI_ID is resolved automatically by create-instance.sh and saved to .state/ami-id
KEY_PAIR_NAME="aws-build"              # name of the EC2 key pair to use for SSH access
INSTANCE_NAME="hello-build"           # EC2 Name tag used to identify this project's instance
ROOT_VOLUME_SIZE=8                    # root EBS volume size in GB; 8 GB is plenty for hello
# EBS_SIZE intentionally unset — hello binary is tiny; no extra EBS volume needed

REMOTE_USER="ubuntu"                  # login user on the EC2 instance (matches Ubuntu AMI)
REMOTE_SRC="/tmp/hello"              # working directory on EC2 for source files and build output
PAYLOAD_CMD="gcc hello.c -o hello"

# Paths relative to this config file so the projects can live anywhere on disk
_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SRC="$_CONFIG_DIR/../hello-world-example/src"   # source files in the sibling hello-world-example project
LOCAL_BIN="$_CONFIG_DIR/../hello-world-example/bin"   # compiled binary output in the sibling hello-world-example project
STATE_DIR="$_CONFIG_DIR/.state"      # per-project EC2 state files (instance-id, instance-ip)
