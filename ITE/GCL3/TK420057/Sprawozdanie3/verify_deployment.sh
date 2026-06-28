#!/bin/bash

echo "Rozpoczynam weryfikację wdrożenia..."

if minikube kubectl -- rollout status deployment/flask-deployment --timeout=60s; then
    echo "Sukces! Wdrożenie zakończyło się pomyślnie w 60sekund."
    exit 0
else
    echo "Błąd! Wdrożenie zakończyło sie niepowodzeniem w 60 sekund."
    exit 1
fi