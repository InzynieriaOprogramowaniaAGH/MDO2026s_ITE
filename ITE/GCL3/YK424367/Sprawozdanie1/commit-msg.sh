   MSG_FILE="$1"
   MSG="$(sed -n '1p' "$MSG_FILE")"

   PREFIX="YK424367"

   echo "$MSG" | grep -q "^$PREFIX" || {
     echo "No '$PREFIX'" >&2
     exit 1
   }

   exit 0