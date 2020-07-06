#!/bin/bash
#
# Simple DNG-files move script that moves *.DNG files from their original
# location to a newly creates DNGs folder in the same working directory.
# It preserves DNG-files directory structure

CURRENT_WORKING_DIR=$(pwd)
NECESSARY_PARENT="Mavic Panoramas"

# Prevents from running outside of our special parent folder
if [[ ! $CURRENT_WORKING_DIR =~ $NECESSARY_PARENT ]]; then
  echo "You are not under $NECESSARY_PARENT directory"
  exit 1
fi

find . -name "*.DNG" -print0 | while read -d $'\0' file; do
  NEW_DIR=$(dirname "$file")
  echo "Moving files to ./DNGs/$NEW_DIR..."
  mkdir -pv "./DNGs/$NEW_DIR"
  mv "$file" "./DNGs/$NEW_DIR"
done
