#!/bin/bash

TIMEOUT=60s
DEPLOYMENT="moj-deployment"

echo "Weryfikacja wdrożenia: $DEPLOYMENT (Timeout: $TIMEOUT)..."

if kubectl rollout status deployment/$DEPLOYMENT --timeout=$TIMEOUT; then
    echo "Wdrożenie zakończyło się pomyślnie."
    exit 0
else
    echo "BŁĄD: Wdrożenie nie zdążyło się wdrożyć w ciągu $TIMEOUT!"
    exit 1
fi