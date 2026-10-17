#!/usr/bin/env bash
# Delete the local kind cluster created by up.sh

set -euo pipefail

kind delete cluster --name "${CLUSTER_NAME:-corabia}"
