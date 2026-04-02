#!/bin/bash
INPUT_FILE=$1
START_LINE=$(head -n 1 "$INPUT_FILE")
PATTERN="^PB422021"

if [[ ! $START_LINE =~ $PATTERN ]] then
	echo "BŁĄD: Commit message musi zaczynać się od PB422021"
	exit 1
fi
