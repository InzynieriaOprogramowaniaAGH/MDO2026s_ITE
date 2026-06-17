#!/bin/bash
echo "Sprawdzam stan wdrożenia (max 60 sekund)..."

kubectl rollout status deployment/moj-express-deploy --timeout=60s

if [ $? -eq 0 ]; then
    echo "✅ Sukces: Wdrożenie zdążyło się uruchomić!"
else
    echo "❌ Błąd: Wdrożenie nie wyrobiło się w czasie 60s."
    exit 1
fi
