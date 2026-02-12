#!/usr/bin/env bash

# This script pulls information from a website
# Renders and formats it for markdown input
# And returns the result as a string

# Check runtime dependencies
HAS_CURL=0
HAS_HTMLQ=0
CAN_WRITE=0

# requires curl
if [[ ! $(which curl) ]]; then
  printf "This application requires curl to run, but it was not found.\n"
else
  HAS_CURL=1
fi

# requires htmlq
if [[ ! $(which htmlq) ]]; then
  printf "This application requires htmlq to run, but it was not found.\n"
else
  HAS_HTMLQ=1
fi

# after checking for software dependencies, create a temporary directory
SCRAPE_DIR=/tmp/scrape
mkdir -p "$SCRAPE_DIR"
EC1=$?

# check exit code after working directory is created and move into it
if [[ $EC1 == 0 ]]; then
  # navigate to next directory, supressing STDOUT from pushd
  pushd "$SCRAPE_DIR" 1>/dev/null
else
  printf "Unable to create temporary directory. Exit code %s from 'mkdir %s'\n" "$EC1" "$SCRAPE_DIR"
  # use home directory instead as a fallback working directory
  pushd "$HOME" 1>/dev/null
fi

# set other shell variables for this script
declare DOWNLOAD_URL='https://nextjs.org/docs#what-is-nextjs'
declare DOWNLOAD_FILE="$PWD/download_webpage.html"
declare FORMAT_FILE="$PWD/formatted_webpage.html"

# check that the current working directory can be written to
touch "$DOWNLOAD_FILE"
EC2=$?

# check exit code after creating a file in the working directory
if [[ $EC2 == 0 && -f $DOWNLOAD_FILE ]]; then
  CAN_WRITE=1
fi

# if requirements have been met, run the download function
if [[ $CAN_WRITE == 1 && $HAS_CURL == 1 && $HAS_HTMLQ == 1 ]]; then
  # send a GET request with tool header, indicating that
  # this request is from `curl`
  # append data to headers instead of POST body with --head/-I
  curl --get --data "tool=curl" \
    --retry-delay 5 --retry 7 "$DOWNLOAD_URL" >"$DOWNLOAD_FILE"
fi

# check that the results are non-empty
if [[ ! -s $DOWNLOAD_FILE ]]; then
  printf "%s" "ERROR: The file: $DOWNLOAD_FILE is empty." 1>&2
fi

# format the webpage using `htmlq`
# select only the paragraph elements using a CSS selector
cat "$DOWNLOAD_FILE" | htmlq -Bpwt -- 'p' >"$FORMAT_FILE"
EC3=$?

# print terminating statements
if [[ $EC3 == 0 ]]; then
  printf "%s\n" "SUCCESS: The file $FORMAT_FILE was created."
else
  printf "%s\n" "ERROR: The file '$FORMAT_FILE' was not created / htmlq failed with error. Exit code: $EC3" 1>&2
fi

# return to original directory, supressing STDOUT from popd
popd 1>/dev/null

# cleanup shell variables
unset DOWNLOAD_URL DOWNLOAD_FILE FORMAT_FILE
