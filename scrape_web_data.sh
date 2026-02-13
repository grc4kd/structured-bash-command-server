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

# Default values
DOWNLOAD_URL='https://owasp.org/Top10/2025/'
OUTPUT_FILE="SBCS-temp-output-$(date +%s).html"
CSS_SELECTOR='p'

# Print usage
usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -u, --url URL             Set the URL to scrape (default: $DOWNLOAD_URL)"
  echo "  -o, --output FILE         Set output filename (default: $OUTPUT_FILE)"
  echo "  -s, --selector CSS_SELECTOR"
  echo "      Set output filename (default: $OUTPUT_FILE)"
  echo "  -h, --help                Show this help message"
  exit 1
}

# Parse command-line options
while [[ $# -gt 0 ]]; do
  case $1 in
  -u | --url)
    DOWNLOAD_URL="$2"
    shift 2
    ;;
  -o | --output)
    OUTPUT_FILE="$2"
    shift 2
    ;;
  -s | --selector)
    CSS_SELECTOR="$2"
    shift 2
    ;;
  -h | --help)
    usage
    ;;
  *)
    echo "Unknown option: $1"
    usage
    ;;
  esac
done

# Check runtime dependencies
HAS_CURL=0
HAS_HTMLQ=0
CAN_WRITE=0

if [[ ! $(which curl) ]]; then
  log "This application requires curl to run, but it was not found."
else
  HAS_CURL=1
fi

if [[ ! $(which htmlq) ]]; then
  log "This application requires htmlq to run, but it was not found."
else
  HAS_HTMLQ=1
fi

# Create a temporary directory
SCRAPE_DIR=/tmp/scrape
mkdir -p "$SCRAPE_DIR"
EC1=$?

if [[ $EC1 == 0 ]]; then
  pushd "$SCRAPE_DIR" 1>/dev/null
else
  log "Unable to create temporary directory. Exit code $EC1 from 'mkdir $SCRAPE_DIR'"
  pushd "$HOME" 1>/dev/null
fi

# Set other shell variables for this script
declare DOWNLOAD_FILE="$PWD/scraped_page.html"
declare FORMAT_FILE="$PWD/$OUTPUT_FILE"
declare HTMLQ_SELECTOR="$CSS_SELECTOR"

# Check that the current working directory can be written to
touch "$DOWNLOAD_FILE"
EC2=$?

if [[ $EC2 == 0 && -f $DOWNLOAD_FILE ]]; then
  CAN_WRITE=1
fi

# If requirements have been met, run the download function
if [[ $CAN_WRITE == 1 && $HAS_CURL == 1 && $HAS_HTMLQ == 1 ]]; then
  curl -G -d "tool=curl" -H "Accept: text/html" \
    --max-time 30 --retry 7 \
    "$DOWNLOAD_URL" >"$DOWNLOAD_FILE"
fi

# Check that the results are non-empty
if [[ ! -s $DOWNLOAD_FILE ]]; then
  log "ERROR: The file: $DOWNLOAD_FILE is empty."
  exit 1
fi

# Format the webpage using `htmlq`
cat "$DOWNLOAD_FILE" | htmlq -Bpwt -- "$CSS_SELECTOR" >"$FORMAT_FILE"
EC3=$?

if [[ $EC3 == 0 ]]; then
  log "SUCCESS: The file $FORMAT_FILE was created."
else
  log "ERROR: The file '$FORMAT_FILE' was not created / htmlq failed with error. Exit code: $EC3"
  exit 1
fi

# Return to original directory
popd 1>/dev/null

# Cleanup shell variables
unset DOWNLOAD_URL CSS_SELECTOR DOWNLOAD_FILE FORMAT_FILE
