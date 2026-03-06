#!/bin/bash

commit_msg=$(cat "$1")

if [[ ! $commit_msg =~ "MK421268" ]]; then
  echo "Error: prefix JK417545 nedded in commit"
  exit 1
fi
