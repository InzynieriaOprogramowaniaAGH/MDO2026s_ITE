#!/bin/bash

message=$(cat $1)
prefix="TK420057"

if [[ $message != $prefix* ]]; then
    echo "Commit message must start with $prefix"
    exit 1
fi
