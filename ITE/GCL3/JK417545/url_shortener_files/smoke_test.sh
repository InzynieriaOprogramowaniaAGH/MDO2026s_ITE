#!/bin/bash

URL_FILE=$1
APP_URL="http://docker:3000"

if [ ! -f "$URL_FILE" ]; then
    echo "ERROR: File $URL_FILE not found!"
    exit 1
fi

while read -r url || [ -n "$url" ]; do
    [ -z "$url" ] && continue
    echo "------------------------------------------"
    echo "Testing URL: $url"
    
    # 1. POST tworzy shorturl
    RESPONSE=$(curl -s -X POST "$APP_URL/url/tinyUrl" \
        -H 'Content-Type: application/json' \
        -d "{\"longUrl\": \"$url\"}")
    
    SHORT_CODE=$(echo "$RESPONSE" | grep -oE '"shortUrl":"[^"]+"' | sed 's/.*\/ \([^"]*\)"/\1/')
    
    if [ -z "$SHORT_CODE" ]; then
        echo "ERROR: Failed to get short code for $url"
        echo "Response was: $RESPONSE"
        exit 1
    fi
    
    echo "Generated code: $SHORT_CODE"

    # 2. GET check czy dziala
    CHECK=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL/url/tinyUrl?shortUrl=$SHORT_CODE")
    
    if [ "$CHECK" != "200" ]; then
        echo "ERROR: URL $url (code $SHORT_CODE) not resolved! HTTP Status: $CHECK"
        exit 1
    fi
    
    echo "SUCCESS: $url resolved correctly."
done < "$URL_FILE"

echo "------------------------------------------"
echo "ALL TESTS PASSED SUCCESSFULLY"
exit 0
