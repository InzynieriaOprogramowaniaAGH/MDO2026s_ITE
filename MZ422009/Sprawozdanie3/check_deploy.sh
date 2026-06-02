#!/bin/bash
for i in {1..60}
do
    READY=$(kubectl get deployment lab10-app -o jsonpath='{.status.readyReplicas}')
    DESIRED=$(kubectl get deployment lab10-app -o jsonpath='{.spec.replicas}')
    echo "Sekunda $i: ready=$READY desired=$DESIRED"
    if [ "$READY" = "$DESIRED" ] && [ -n "$READY" ]; then
        echo "Wdrozenie zakonczylo sie poprawnie"
        exit 0
    fi
    sleep 1
done
echo "Wdrozenie nie osiagnelo wymaganego stanu w 60 sekund"
exit 1
