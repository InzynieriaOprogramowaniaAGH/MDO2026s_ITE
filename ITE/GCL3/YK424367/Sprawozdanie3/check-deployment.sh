#!/bin/bash
DEPLOYMENT=${1:-nginx-deployment}
TIMEOUT=60

echo "Checking deployment: $DEPLOYMENT (timeout: ${TIMEOUT}s)"

if minikube kubectl -- rollout status deployment/$DEPLOYMENT --timeout=${TIMEOUT}s; then
    echo "SUCCESS: Deployment $DEPLOYMENT rolled out within ${TIMEOUT}s"
    exit 0
else
    echo "FAILED: Deployment $DEPLOYMENT did not complete within ${TIMEOUT}s"
    minikube kubectl -- get pods -l app=nginx
    exit 1
fi
