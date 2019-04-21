#!/bin/bash
#
# Runs exiftool to clean up and update panorama image meta tags. Provides
# a routine commands for Mavic Pro panorama files.
#
# It takes a filename with manually prepared Panorama (with Photoshop,
# for example), cleans its meta tags, copies meta tags from the first original
# panorama files (to set coordinates, camera information, ISO, etc.), and adds
# some additional meta tags to make it fit Google Photos or Facebook panoramas
# requirements.
#
# Supposed to be run in the panorama source files folder (that contains donor
# file - the first one done by Mavic)

IMAGE=$1
ORIGINAL_SUFFIX="_original"
DONOR_IMAGE="PANO0001.JPG"
EXIFCMD="exiftool"

echo ":[||||||]: my_pano.sh"

if [ ! $1 ]; then
  echo "Please, provide a filename to update its meta tags"
  exit 1
fi

for file in $IMAGE $DONOR_IMAGE; do
  if [ ! -f "$file" ]; then
    echo "$file is unavailable"
    exit 1
  fi
done

if [ ! -x "$(command -v $EXIFCMD)" ]; then
  echo "Please, install $EXIFCMD first"
  exit 1
fi

echo "Clean up all meta tags"
$EXIFCMD -all= $IMAGE
echo "Copy meta tags from donor file"
$EXIFCMD -TagsFromFile $DONOR_IMAGE $IMAGE
echo "Set additional meta tags"
$EXIFCMD -Make="RICOH" -Model="RICOH THETA S" -ProjectionType="equirectangular" -UsePanoramaViewer="True" -CroppedAreaLeftPixels="0" -CroppedAreaTopPixels="0" $IMAGE
echo "Remove original file"
rm "$IMAGE$ORIGINAL_SUFFIX"
echo "Done"
