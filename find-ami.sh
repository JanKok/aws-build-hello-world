#!/usr/bin/env bash
# aws-build-hello-world/find-ami.sh — Find suitable AMIs for this project.
# Prints matching AMIs (region, ID, name) across the configured search regions.

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

export AMI_OWNER=""              # Search across all owners.
#export AMI_OWNER="099720109477"  # Canonical's AWS account (official Ubuntu AMIs only)

OS_TYPE="ubuntu"                 # OS name as it appears in the AMI name path
# OS_VERSION is the tricky part. The official Ubuntu AMIs have names like
# "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20241017", so the
# version is embedded in the middle of the name. To match a specific version,
# you can use a filter like "20.04". To match any version, you can use a
# wildcard like "*". The "?" wildcard matches any single character. Other
# wildcards are not allowed by the AWS CLI. The pattern "??.04" will match any
# LTS since all Ubuntu LTS releases use .04 as the minor version. The exact
# pattern you use will depend on your needs for stability vs. freshness in the
# build environment.

#OS_VERSION="24.04"               # Ubuntu version to match; e.g. "22.04" to pin, "*" for any
OS_VERSION="20.04"               # Ubuntu version to match; e.g. "22.04" to pin, "*" for any
    # Use 18.04 LTS (Bionic) because that is the Ubuntu version used in the
    # official Xilinx Vitis AI AMI, which is a common base image for Kria
    # builds. Newer versions of Ubuntu may work but haven't been tested with
    # this project yet, so 18.04 is the safest choice for now. If you want to
    # experiment with newer versions, you can change this to "20.04" or "22.04"
    # or "*" for any version, but be aware that you may run into unexpected
    # issues if the environment differs significantly from 18.04.
OS_ARCH="amd64"                  # architecture; use "arm64" for Graviton instances
VIRT_STORAGE="*"                 # virtualization+storage type; e.g. "hvm-ssd", "hvm-ssd-gp3", or "*" for any

export AMI_NAME_FILTER="$OS_TYPE/images/$VIRT_STORAGE/$OS_TYPE-*-$OS_VERSION-$OS_ARCH-server-*"

export SEARCH_AWS_REGIONS="$AWS_REGION"   # Search in the specified region
 export SEARCH_AWS_REGIONS="*"            # Search in all regions
# export SEARCH_AWS_REGIONS="us-*"         # Search in all US regions

"$AWS_BUILD_UTILS/find-ami.sh"
