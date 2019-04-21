#!/bin/bash
#
# Read more about codecs: https://ffmpeg.org/ffmpeg-codecs.html#ProRes
# My choice here: ProRes 422 LT (profile 0 in ffmpeg)

echo ":[||||||]: convert_to_prores.sh"
echo "Working in `pwd`"

DJI_ENCODER_STRING="Dji AVC encoder"
FILES_TO_CONVERT=`ls *.{MP4,MOV}`

for file in $FILES_TO_CONVERT; do
  filename=$(basename -- "$file")
  extension="${filename##*.}"
  filename="${filename%.*}"

  encoder=`ffprobe $file -hide_banner 2>&1 | grep 'Dji AVC encoder' | awk '{print $3 " " $4 " " $5}'`

  if [ "$encoder" == "$DJI_ENCODER_STRING" ]; then
    echo ":[||||||]: Processing $file (original encoder: $encoder)..."
    ffmpeg -y -i "$file" -vcodec prores -profile:v 0 "$filename.422lt.$extension" && rm $file
  fi
done
