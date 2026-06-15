#!/bin/bash

DEPLOYMENT_NAME="petclinic-deployment"
echo "Sprawdzanie statusu wdrożenia: $DEPLOYMENT_NAME (Limit: 60 sekund)..."

if kubectl rollout status deployment/$DEPLOYMENT_NAME --timeout=60s; then
    echo "✅ Sukces: Wdrożenie zakończyło się poprawnie w wymaganym czasie."
    exit 0
else
    echo "❌ Błąd: Wdrożenie nie powiodło się lub przekroczyło limit 60 sekund!"
    exit 1
fi