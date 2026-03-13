#!/bin/sh

if ! grep -qE '^KB422046' "$1"; then
    echo >&2 "Commit message must start with KB422046"
    exit 1
fi