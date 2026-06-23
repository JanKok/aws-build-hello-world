#!/usr/bin/env bash
# aws-build-hello-world/config.sh — Configuration for the hello-world EC2 build project.
# Source this file at the top of every script in this project.

# Get the paths to 3 important projects:
# AWS_BUILD_CONFIG — this project, which contains config.sh and get-ami-id.sh
export AWS_BUILD_CONFIG="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# AWS_BUILD_UTILS — shared utilities for AWS build operations (launch, stop, ssh, etc.)
export AWS_BUILD_UTILS="$(cd "$AWS_BUILD_CONFIG/../aws-build-utils" && pwd)"
# PROJECT - the root of the actual project being built (hello-world-example in this case)
export PROJECT_NAME="hello-world-example"
export PROJECT="$(cd "$AWS_BUILD_CONFIG/../$PROJECT_NAME" && pwd)"

export STATE_DIR="$AWS_BUILD_CONFIG/.state"     # per-project EC2 state files (instance-id, instance-ip)

source "$AWS_BUILD_UTILS/config.sh"             # pulls in AWS_REGION and SSH_KEY_PATH

# === These variables are used by create-instance.sh to configure the new instance.

export INSTANCE_TYPE="t3.micro"                 # EC2 instance type; t3.micro is cheap and sufficient for gcc
export INSTANCE_PRICE_PER_HOUR="0.0104"         # t3.micro on-demand price in us-east-1; verify at aws.amazon.com/ec2/pricing
# AMI_ID is resolved automatically by create-instance.sh and saved to .state/ami-id
export AMI_ID="ami-028791b62b23efdd9"           # AMI ID to use for the EC2 instance
export KEY_PAIR_NAME="aws-build"                # name of the EC2 key pair to use for SSH access
export INSTANCE_NAME="hello-build"              # EC2 Name tag used to identify this project's instance
export ROOT_VOLUME_SIZE=8                       # root EBS volume size in GB; 8 GB is plenty for hello
# EBS_SIZE intentionally unset — hello binary is tiny; no extra EBS volume needed

# === These variables are used by rsync to sync files between your local machine and the EC2 instance.

export REMOTE_USER="ubuntu"                     # login user on the EC2 instance (matches Ubuntu AMI)
# path on EC2 for source files and build output; using /tmp since we don't
# need persistence or extra space for this simple project.
export REMOTE_PROJECT="/tmp/$PROJECT_NAME"
export REMOTE_SRC="$REMOTE_PROJECT/src"         # source files in the project
export REMOTE_BIN="$REMOTE_PROJECT/bin"         # compiled binary output in the project
export LOCAL_SRC="$PROJECT/src"                 # source files in the project
export LOCAL_BIN="$PROJECT/bin"                 # compiled binary output in the project

# For local to remote rsync, don't sync .git and build folders.
export RSYNC_EXTRA_OPTS="--exclude=.git --exclude=bin"

# === PAYLOAD_CMD is the command that will be run to perform the build.

# NOTE! In order to work with both local and remote builds, $SRC and $BIN will be set to
# the paths to the source and binary directories on the machine where the build is executed.
# build.sh (remote build on AWS server) sets SRC=$REMOTE_SRC and BIN=$REMOTE_BIN before running PAYLOAD_CMD.
# local-build.sh (build on your local PC) sets SRC=$LOCAL_SRC and BIN=$LOCAL_BIN before running PAYLOAD_CMD.
export PAYLOAD_CMD='gcc $SRC/hello.c -o $BIN/hello'
