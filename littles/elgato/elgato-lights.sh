#!/bin/bash

set -euo pipefail

# Automatic switch (on/off) of configured Elgato light devices.
#
# This (macOS-only!) script supposed to run in background all the time. We can configure to run it
# in background after macOS starts using launchctl like this:
#
# cp ~/.dotfiles/littles/elgato-lights.plist ~/Library/LaunchAgents/
# launchctl load ~/Library/LaunchAgents/elgato-lights.plist
#
# P.S. The original idea was picked up here: https://github.com/adamesch/elgato-key-light-api

# To let the lights work, we have to provide a few settings:

TEMPERATURE=4250 # 2900–6950K
BRIGHTNESS=50 # 1–100
DEVICES_IPS=(192.168.1.90 192.168.1.91 192.168.1.93) # TODO: move devices' IPs list somewhere...

# Converts a color temperature (in K) to the format Elgato Lights like (e.g., integer from 143–344)
#
# NOTE: the actual precision is not ideal. Likely, we need to find a better way on how to convert
# the color temperatue.
function kelvin_to_elgato() {
  echo "" | awk "END {print int((987007 * $1 ^ -0.999)) }"
}

# Builds a full API url to the light using the given IP address
function api_url() {
  echo "http://$1:9123/elgato/lights"
}

# Uses `curl` to send the given data to the given url using PUT-request.
function send_put() {
  URL=$1
  DATA=$2

  curl --silent --output /dev/null --request PUT $URL --header 'Content-Type: application/json' --data-raw $DATA
}

# Switches the given light on
function on() {
  URL=$(api_url $1)
  TEMP=$(kelvin_to_elgato $2)
  BRIGHT=$3

  DATA="{\"lights\":[{\"brightness\":$BRIGHT,\"temperature\":$TEMP,\"on\":1}],\"numberOfLights\":1}"

  send_put $URL $DATA
}

# Switches the given light off
function off() {
  URL=$(api_url $1)

  DATA="{\"lights\":[{\"on\":0}]}"

  send_put $URL $DATA
}

# ...camera, action!
function lights_on() {
  for light in "${DEVICES_IPS[@]}"; do
    on $light $TEMPERATURE $BRIGHTNESS
  done
}

# ...cut!
function lights_off() {
  for light in "${DEVICES_IPS[@]}"; do
    off $light
  done
}

# Here is the main piece of the functionality of this script: we use `log` command and predicate
# option to filter camera on and off events. We take the input and switch on or off the ligths
# configured at the top of this file.

CAMERA_EVENTS='subsystem == "com.apple.UVCExtension" AND composedMessage CONTAINS "Post PowerLog"'

log stream --predicate "$CAMERA_EVENTS" | while read LOGLINE; do
  if [[ $LOGLINE == *"= On"* ]]; then
    # echo "Camera has been activated"
    lights_on
  fi

  if [[ $LOGLINE == *"= Off"* ]]; then
    # echo "Camera has been deactivated"
    lights_off
  fi
done
