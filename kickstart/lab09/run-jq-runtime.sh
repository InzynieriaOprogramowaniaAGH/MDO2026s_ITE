#!/bin/bash
set -eux

mkdir -p /opt/jq-runtime
cd /opt/jq-runtime

curl -L -o jq-runtime.tar http://10.10.10.10:8000/jq-runtime-3.tar

podman load -i jq-runtime.tar

echo '{"answer":42}' | podman run --rm -i jq-runtime:3 '.answer' > /opt/jq-runtime/result.txt

echo "Lab09 first boot script executed" > /opt/jq-runtime/status.txt
