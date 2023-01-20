#!/bin/bash
#
# Checks maximum loud levels for files in the given directory.
#
# Reads all MP3 files in the given directory, "listens" to them, saves loud levels (every second)
# to the temp log file, then aggregate this log file (via awk) and saves average, maximum, and
# minimum loud levels to the *.stats file with the same name as MP3 counterpart.

if ! docker version > /dev/null 2>&1; then
  echo "Docker is not available. This script relies on the dockerized version of ffmpeg!"
  exit 1
fi

if [ ! $1 ]; then
  echo "Please, provide an absolute path to directory with MP3 files to be checked, e.g.:"
  echo "$0 /home/$USER/music"
  exit 2
fi

INPUT_DIR=${1%/}
FF_VERSION=jrottenberg/ffmpeg:5.1-alpine

echo "Audio maximum volume check for MP3 files"
echo "Input: $INPUT_DIR"
echo "---"

find $INPUT_DIR -type f -iname "*.mp3" | while read file
do
  BASENAME=`basename "$file"`
  OUTPUT_STATS="${INPUT_DIR}/${BASENAME%%.*}.stats"
  LEVELS_LOG="${INPUT_DIR}/levels.log"
  TS=$(date '+%T')

  echo "${TS}: ${BASENAME}"

  docker run --rm -v $INPUT_DIR:$INPUT_DIR -w $INPUT_DIR \
         $FF_VERSION -hide_banner -loglevel error -nostdin -i "$file" \
         -af astats=metadata=1:reset=1,ametadata=print:key=lavfi.astats.Overall.RMS_level:file=$LEVELS_LOG \
         -f null -

  grep 'lavfi.astats.Overall.RMS_level' "$LEVELS_LOG" \
  | awk 'FS="=" {if (min == "") {min = max = $2}; if ($2 > max) {max = $2}; if ($2 < min) {min = $2}; total += $2; count += 1} END {print total/count, max, min}' \
  > "$OUTPUT_STATS"

  rm -f "$LEVELS_LOG"
done
