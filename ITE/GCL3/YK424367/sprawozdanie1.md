```sh
MSG_FILE="$1"
MSG="$(sed -n '1p' "$MSG_FILE")"

PREFIX="YK424367"

echo "$MSG" | grep -q "^$PREFIX" || {
  echo "No '$PREFIX'" >&2
  exit 1
}

exit 0
```

## Zrzuty ekranu

![VM](Screenshot%202026-03-03%20at%2009.27.05.png)

![Klonowanie repozytorium po SSH](Screenshot%202026-03-03%20at%2009.38.40.png)