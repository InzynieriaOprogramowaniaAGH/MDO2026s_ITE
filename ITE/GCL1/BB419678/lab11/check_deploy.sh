#!/bin/bash
# sprawdzamy przez 60 sekund
kubectl rollout status deployment/lab-deployment --timeout=60s

if [ $? -eq 0 ]; then
    echo "SUKCES: Wdrozenie udane i zdazylo wstac w 60s!"
else
    echo "PORAZKA: Wdrozenie zawislo lub napotkalo problem (np. CrashLoopBackOff)."
    exit 1
fi