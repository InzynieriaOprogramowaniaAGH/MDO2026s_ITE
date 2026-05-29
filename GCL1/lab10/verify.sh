#!/bin/bash
echo "Sprawdzam status klastra..."
kubectl rollout status deployment/nginx-deployment --timeout=60s