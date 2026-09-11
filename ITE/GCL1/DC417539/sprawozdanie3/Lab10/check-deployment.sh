#!/bin/bash

echo "Sprawdzanie wdrozenia lab10-nginx..."

if minikube kubectl -- rollout status deployment/lab10-nginx --timeout=60s
then
    echo "Wdrozenie zakonczylo sie w czasie do 60 sekund."
    exit 0
else
    echo "Wdrozenie nie zakonczylo sie w ciagu 60 sekund."
    exit 1
fi
