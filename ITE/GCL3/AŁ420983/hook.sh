#!/bin/bash
commit_msg_file=$1
commit_msg=$(cat "$commit_msg_file")

pattern="^AŁ420983"

if [[ ! $commit_msg =~ $pattern ]]; then
  echo "BŁĄD: Wiadomość commita musi zaczynać się od: AŁ420983"
  exit 1
fi