#!/bin/bash
echo "START"
kubectl rollout status deployment/nginx-wdrozenie --timeout=60s
if [ $? -eq 0 ]; then
  echo "Ponizej 60 sekund"
else
  echo "Powyzej 60 sekund"
  exit 1
fi