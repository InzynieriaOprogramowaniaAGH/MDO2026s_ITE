#!/usr/bin/env bash
set -euo pipefail

JQ="/opt/jq/jq"

pass=0
fail=0

run_test() {
    name="$1"
    input="$2"
    filter="$3"
    expected="$4"

    echo "Running test: $name"

    actual="$(printf "%s\n" "$input" | "$JQ" -r "$filter")"

    if [ "$actual" = "$expected" ]; then
        echo "PASS: $name"
        pass=$((pass + 1))
    else
        echo "FAIL: $name"
        echo "Expected: $expected"
        echo "Actual:   $actual"
        fail=$((fail + 1))
    fi

    echo
}

echo "jq version:"
"$JQ" --version
echo

run_test "extract number from object" \
    '{"answer":42}' \
    '.answer' \
    '42'

run_test "array length" \
    '[1,2,3,4]' \
    'length' \
    '4'

run_test "nested object field" \
    '{"user":{"name":"Jan"}}' \
    '.user.name' \
    'Jan'

run_test "array mapping" \
    '[1,2,3]' \
    'map(. * 2) | join(",")' \
    '2,4,6'

echo "============================================================================"
echo "Functional test summary"
echo "============================================================================"
echo "# PASS: $pass"
echo "# FAIL: $fail"
echo "============================================================================"

if [ "$fail" -ne 0 ]; then
    exit 1
fi
