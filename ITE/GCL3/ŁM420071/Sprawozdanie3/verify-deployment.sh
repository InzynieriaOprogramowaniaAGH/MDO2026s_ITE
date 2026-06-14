#!/bin/bash

if minikube kubectl -- rollout status deployment/express-deployment --timeout=60s; then
    exit 0
else
    exit 1
fi