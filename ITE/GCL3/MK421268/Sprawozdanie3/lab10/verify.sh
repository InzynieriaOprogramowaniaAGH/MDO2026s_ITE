#!/bin/bash
DEPLOYMENT_NAME="app-deployment"
TIMEOUT=60
START_TIME=$(date +%s)

KUBE_CMD="minikube kubectl --"

echo "Rozpoczynam monitorowanie wdrożenia $DEPLOYMENT_NAME..."

while true; do
  CURRENT_TIME=$(date +%s)
  ELAPSED=$((CURRENT_TIME - START_TIME))

  if [ $ELAPSED -gt $TIMEOUT ]; then
    echo "[BŁĄD] Wdrożenie przekroczyło limit czasu $TIMEOUT sekund!"
    exit 1
  fi

  # Pobranie liczby pożądanych i gotowych replik za pomocą zmiennej KUBE_CMD
  DESIRED=$($KUBE_CMD get deployment $DEPLOYMENT_NAME -o jsonpath='{.spec.replicas}')
  READY=$($KUBE_CMD get deployment $DEPLOYMENT_NAME -o jsonpath='{.status.readyReplicas}')

  # Zabezpieczenie przed pustymi wartościami (zanim pody wstaną)
  if [ -z "$READY" ]; then READY=0; fi
  if [ -z "$DESIRED" ]; then DESIRED=0; fi

  echo "Status: Gotowe $READY z $DESIRED replik... (Minęło: ${ELAPSED}s)"

  if [ "$READY" -eq "$DESIRED" ] && [ "$DESIRED" -gt 0 ]; then
    echo "[SUKCES] Wdrożenie zakończone pomyślnie w czasie ${ELAPSED}s!"
    exit 0
  fi

  sleep 3
done