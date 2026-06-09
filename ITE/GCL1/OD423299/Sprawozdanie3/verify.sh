#!/bin/bash
DEPLOYMENT="oskar-web-deployment"
TIMEOUT="60s"

echo "Sprawdzamie statusu wdrożenia: $DEPLOYMENT (limit czasu: $TIMEOUT)..."

if kubectl rollout status deployment/$DEPLOYMENT --timeout=$TIMEOUT; then
    echo "Wdrożenie zakończyło się pomyślnie przed upływem czasu."
    exit 0
else
    echo "Wdrożenie nie ustabilizowało się w ciągu 60 sekund! Prawdopodobnie pętla błędów."
    exit 1
fi