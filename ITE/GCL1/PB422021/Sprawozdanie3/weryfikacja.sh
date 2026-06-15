#!/bin/bash
echo "Kontrola wdrożenia..."
minikube kubectl -- rollout status deployment/profesjonalne-wdrozenie --timeout=60s

if [ $? -eq 0 ]; then
    echo "Wdrożenie zakończyło się sukcesem w wyznaczonym czasie"
else
    echo "Błąd: Wdrożenie nie zdążyło się ukończyć w 60 sekund."
fi
