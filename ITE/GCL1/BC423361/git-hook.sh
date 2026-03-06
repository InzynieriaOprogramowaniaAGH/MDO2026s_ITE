#!/bin/bash
MSG=$(cat "$1")
if [[ ! $MSG =~ ^BC423361 ]]; then
  echo "zly index"
  exit 1
fi