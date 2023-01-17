#!/bin/bash
#
# Audio normalization for MP3 files via (dockerized) ffmpeg. See more:
# - http://johnriselvato.com/ffmpeg-how-to-normalize-audio/
# - https://ffmpeg.org/ffmpeg-filters.html#loudnorm
# - https://hub.docker.com/r/jrottenberg/ffmpeg

if ! docker version > /dev/null 2>&1; then
  echo "Docker is not available. This script relies on the dockerized version of ffmpeg!"
  exit 1
fi

if [ ! $1 ]; then
  echo "Please, provide an absolute path to directory with MP3 files to be normalized, e.g.:"
  echo "$0 /home/$USER/music"
  exit 2
fi

INPUT_DIR=$1
OUTPUT_DIR="${INPUT_DIR%/}_normalized"
FF_VERSION=jrottenberg/ffmpeg:5.1-alpine

mkdir -p "$OUTPUT_DIR"

echo "Audio normalization for MP3 files"
echo "Input: $INPUT_DIR"
echo "Output: $OUTPUT_DIR"
echo "---"

find $INPUT_DIR -type f -iname "*.mp3" | while read file
do
  BASENAME=`basename "$file"`
  OUTPUT_FILE="${OUTPUT_DIR}/${BASENAME}"
  TS=$(date '+%T')

  echo "${TS}: ${BASENAME}"

  docker run --rm -v $INPUT_DIR:$INPUT_DIR -v $OUTPUT_DIR:$OUTPUT_DIR -w $INPUT_DIR \
         $FF_VERSION -hide_banner -loglevel warning -y -i "$file" -stats -af loudnorm "$OUTPUT_FILE"
done
