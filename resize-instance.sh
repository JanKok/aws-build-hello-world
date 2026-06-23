#!/usr/bin/env bash
# aws-build-hello-world/resize-instance.sh — Change the hello-build EC2 instance type.
# Usage: resize-instance.sh <instance-type>  (e.g. t3.small)
set -e

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
"$AWS_BUILD_UTILS/resize-instance.sh" "$@"
