#!/usr/bin/env bash
set -euo pipefail

DEPLOYMENT="${1:-web-deploy}"
NAMESPACE="${2:-default}"

minikube kubectl -- rollout status "deployment/${DEPLOYMENT}" -n "${NAMESPACE}" --timeout=60s