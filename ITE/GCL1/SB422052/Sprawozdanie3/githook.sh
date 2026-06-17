#!/bin/bash
if ! grep -q "^SB422052" "$1"; then echo "BLAD: Wiadomosc musi zaczynac sie od SB422052"; exit 1; fi
