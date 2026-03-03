# Sprawozdanie lab1 03.03.2026

hook:

```bash
#!/bin/bash

commit_msg=$(cat "$1")

if [[ ! $commit_msg =~ "JK417545" ]]; then
  echo "Error: prefix JK417545 nedded in commit"
  exit 1
fi
```