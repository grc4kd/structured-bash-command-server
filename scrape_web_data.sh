#!/usr/bin/env bash

## This script performs the following operations:
# 1. pull information from a website via HTTP request
# 2. render and format HTML text
# 3. marshall/format HTML for markdown input file --> used later as a prompt/query to LLM.
# returns: a string containing formatted markdown text, obtained by downloading and parsing a single web page's text contents

# script functions
log() {
  printf "$(date '+%Y-%m-%d %H:%M:%S') - %s\n" "$1"
}

# Check runtime dependencies
HAS_CURL=0
HAS_HTMLQ=0
CAN_WRITE=0

# requires curl
if [[ ! $(which curl) ]]; then
  log "$(printf "This application requires curl to run, but it was not found.\n")"
else
  HAS_CURL=1
fi

# requires htmlq
if [[ ! $(which htmlq) ]]; then
  log "$(printf "This application requires htmlq to run, but it was not found.\n")"
else
  HAS_HTMLQ=1
fi

# NO early exits, set minimum state for this script and check for each operation instead.

# after checking for software dependencies, create a temporary directory
SCRAPE_DIR=/tmp/scrape
mkdir -p "$SCRAPE_DIR"
EC1=$?

# check exit code after working directory is created and move into it
if [[ $EC1 == 0 ]]; then
  # navigate to next directory, suppressing STDOUT from pushd
  pushd "$SCRAPE_DIR" 1>/dev/null
else
  log "$(printf "Unable to create temporary directory. Exit code %s from 'mkdir %s'\n" "$EC1" "$SCRAPE_DIR")"
  # use home directory instead as a fallback working directory
  pushd "$HOME" 1>/dev/null
fi

# set other shell variables for this script
declare DOWNLOAD_URL='https://owasp.org/Top10/2025/'
declare HTMLQ_CSS_SELECTOR='span.md-ellipsis'
declare DOWNLOAD_FILE="$PWD/owasp_Top10_2025_down.html"
declare FORMAT_FILE="$PWD/owasp-top10-2025.html"

# check that the current working directory can be written to
touch "$DOWNLOAD_FILE"
EC2=$?

# check exit code after creating a file in the working directory
if [[ $EC2 == 0 && -f $DOWNLOAD_FILE ]]; then
  CAN_WRITE=1
fi

# if requirements have been met, run the download function
if [[ $CAN_WRITE == 1 && $HAS_CURL == 1 && $HAS_HTMLQ == 1 ]]; then
  # send a GET request with POST data for tool, indicating that
  # this request is from the `curl` program.
  curl --get --data "tool=curl" \
    --max-time 30 --retry 7 "$DOWNLOAD_URL" \
    >"$DOWNLOAD_FILE"
fi

# check that the results are non-empty
if [[ ! -s $DOWNLOAD_FILE ]]; then
  log "$(printf "%s" "ERROR: The file: $DOWNLOAD_FILE is empty.")" 1>&2
fi

# format the webpage using `htmlq`
# select only the paragraph elements using a CSS selector
cat "$DOWNLOAD_FILE" | htmlq -Bpwt -- "$HTMLQ_CSS_SELECTOR" >"$FORMAT_FILE"
EC3=$?

# print terminating statements
if [[ $EC3 == 0 ]]; then
  log "$(printf "%s\n" "SUCCESS: The file $FORMAT_FILE was created.")"
else
  log "$(printf "%s\n" "ERROR: The file '$FORMAT_FILE' was not created / htmlq failed with error. Exit code: $EC3" 1>&2)"
fi

# return to original directory, suppressing STDOUT from popd
popd 1>/dev/null

# cleanup shell variables
unset DOWNLOAD_URL HTMLQ_CSS_SELECTOR DOWNLOAD_FILE FORMAT_FILE
