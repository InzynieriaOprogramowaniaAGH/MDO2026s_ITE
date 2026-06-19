#!/bin/bash

DEPLOYMENT_NAME="redis-deployment"
TIMEOUT=60

echo "Rozpoczynam weryfikację wdrożenia: $DEPLOYMENT_NAME (Limit czasu: ${TIMEOUT}s)..."

# Sprawdzenie statusu rolloutu z twardym limitem czasowym
kubectl rollout status deployment/$DEPLOYMENT_NAME --timeout=${TIMEOUT}s

if [ $? -eq 0 ]; then
    echo "SUKCES: Wdrożenie zakończyło się pomyślnie w zadanym czasie!"
    exit 0
else
    echo "BŁĄD: Wdrożenie przekroczyło limit czasu lub zakończyło się awarią!"
    exit 1
fi
