#!/usr/bin/bash

SCRIPT_FILE=./scrape_web_data.sh

HARD_SCRIPT=$(shellharden --transform "$SCRIPT_FILE") && echo "$HARD_SCRIPT" | diff -s - "$SCRIPT_FILE"

shellharden --check "$SCRIPT_FILE"
SHEXIT=$?

if [[ $SHEXIT == 0 ]]; then
  echo "OK: shellharden did not suggest any changes."
fi

if [[ $SHEXIT == 2 ]]; then
  echo "ERROR: shellharden suggested the changes above."
fi
