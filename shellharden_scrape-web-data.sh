#!/usr/bin/bash

# change to the script directory first
SCRIPT_PATH=$(readlink -f "/proc/$$/cwd")
cd "$SCRIPT_PATH"

declare -A SOURCEFILES
SOURCE_FILES=("scrape_web_data.sh" "shellharden_scrape-web-data.sh")
for srcfile in "${SOURCE_FILES[@]}"; do
  HAS_SUGGESTION=$(shellharden --check "$SCRIPT_PATH/$srcfile")
  if [[ $HAS_SUGGESTION == 2 ]]; then
    echo "WARNING: suggested changes waiting for review."
  elif [[ $HAS_SUGGESTION == 1 ]]; then
    echo "ERROR: error while running automation script"
    echo "Script file path is '$SCRIPT_PATH'"
    break
  fi

  # exits with no output if all files check out
done

# change back to last directory quietly
cd - 1>/dev/null
