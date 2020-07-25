#!/bin/bash
#
# Simple DNG-files move script that moves *.DNG files from their original
# location to a newly creates DNGs folder in the same working directory.
# It preserves DNG-files directory structure

CURRENT_WORKING_DIR=$(pwd)
NECESSARY_PARENT="Mavic Panoramas"
FOLDER_NAME="DNGs"

# Prevents from running outside of our special parent folder
if [[ ! $CURRENT_WORKING_DIR =~ $NECESSARY_PARENT ]]; then
  echo "You are not under $NECESSARY_PARENT directory"
  exit 1
fi

find . -name "*.DNG" -print0 | while read -d $'\0' file; do
  if [[ ! "$file" =~ .*"$FOLDER_NAME".* ]]; then
    NEW_DIR=$(dirname "$file" | sed 's/^\.\///g')
    echo "Moving files to ./$FOLDER_NAME/$NEW_DIR..."
    mkdir -pv "./$FOLDER_NAME/$NEW_DIR"
    mv "$file" "./$FOLDER_NAME/$NEW_DIR"
  fi
done
