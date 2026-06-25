#!/usr/bin/env bash
set -euo pipefail

DEPLOYMENT="${1:-lc417617-web}"
NAMESPACE="${2:-default}"
TIMEOUT="${3:-60s}"

echo "Sprawdzam deployment: ${DEPLOYMENT}"
echo "Namespace: ${NAMESPACE}"
echo "Timeout: ${TIMEOUT}"

minikube kubectl -- -n "${NAMESPACE}" rollout status "deployment/${DEPLOYMENT}" --timeout="${TIMEOUT}"

echo
echo "Stan deploymentu:"
minikube kubectl -- -n "${NAMESPACE}" get deployment "${DEPLOYMENT}"

echo
echo "Pody deploymentu:"
minikube kubectl -- -n "${NAMESPACE}" get pods -l app="${DEPLOYMENT}" -o wide
