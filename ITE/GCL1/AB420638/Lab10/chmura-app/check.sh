echo "Sprawdzam status wdrozenia (Timeout: 60s)..."
if minikube kubectl -- rollout status deployment/apka-deployment --timeout=60s; then
    echo "[SUKCES] Wdrozenie ustabilizowalo sie przed czasem!"
    exit 0
else
    echo "[BLAD] Wdrozenie nie powiodlo sie w ciagu 60 sekund."
    exit 1
fi
EOF