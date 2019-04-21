#!/bin/bash
#
# Checks that all the sources are mounted, and then syncs  `_backup` and
# `_import` directories from LaCie external disk to Airport Time Capsule,
# cleaning deleted files.
#
# What is does is basically this:
# rsync -a --progress --human-readable --delete-after /Volumes/LaCie/_backup/ /Volumes/Data/_backup/
# rsync -a --progress --human-readable --delete-after /Volumes/LaCie/_import/ /Volumes/Data/_import/

FROM="/Volumes/LaCie/"
TO="/Volumes/Data/"
SYNC=("_backup" "_import")

echo ":[||||||]: my_rsync.sh"

for endpoint in $FROM $TO; do
  if [ ! -d "$endpoint" ]; then
    echo "$endpoint is unavailable"
    exit 1
  fi
done

for d in ${SYNC[*]}; do
  echo ":[||||||]: Syncing $FROM$d => $TO$d..."
  rsync -a --progress --human-readable --delete-after "$FROM$d/" "$TO$d/"
done
