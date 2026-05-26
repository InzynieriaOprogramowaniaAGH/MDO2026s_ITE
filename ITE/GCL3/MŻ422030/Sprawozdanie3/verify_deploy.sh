#!/bin/bash

echo " Automatyczna weryfikacja. "
echo " Sprawdzam status. "

minikube kubectl -- rollout status deployment/minimalpy-deployment --timeout=60s

if [ $? -eq 0 ]; then
    echo ""
    echo "SUKCES: Aplikacja została wdrożona."
    exit 0
else
    echo ""
    echo "BŁĄD: Wdrożenie przekroczyło limit lub uległo awarii."
    exit 1
fi
