#!/bin/bash
echo "JQ test"
if [ ! -f "output.json" ]; then
    echo "Error: File output.json doesn't exist!"
    exit 1
fi
jq . output.json > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: incorrect syntax."
    exit 1
fi
STATUS=$(jq -r '.status' output.json)
if [ "$STATUS" = "ok" ]; then
    echo "TEST SUCCESS: jq verfied status as 'ok'."
    exit 0
else
    echo "TEST ERROR: status as '$STATUS'."
    exit 1
fi