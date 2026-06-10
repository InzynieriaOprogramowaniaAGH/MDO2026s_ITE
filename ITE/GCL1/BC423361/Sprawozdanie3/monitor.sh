#!/bin/bash
kubectl rollout status deployment/myapp-deploy --timeout=60s
if [ $? -eq 0 ]; then
  echo "Wdrozenie zakonczone przed uplywem 60 sekund!"
else
  echo "Awaria! Wdrozenie trwa zbyt dlugo."
fi
