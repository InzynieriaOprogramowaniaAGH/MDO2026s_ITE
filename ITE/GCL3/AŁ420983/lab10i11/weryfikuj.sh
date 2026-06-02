#!/bin/bash
echo "Rozpoczynam weryfikację wdrożenia fastify-deployment..."

# Sprawdzamy stan rolloutu z limitem 60 sekund
minikubctl rollout status deployment/fastify-deployment --timeout=60s

# Sprawdzamy kod wyjścia (exit code) poprzedniego polecenia
if [ $? -eq 0 ]; then
    echo "[SUKCES] Wdrożenie zakończyło się pomyślnie w czasie poniżej 60 sekund!"
    exit 0
else
    echo "[BŁĄD] Wdrożenie przekroczyło limit 60 sekund lub zakończyło się awarią!"
    exit 1
fi
