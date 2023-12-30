#!/bin/bash

# This macOS-only script supposed to run in background all the time: it automatically switches
# on and off configured Elgato lights.
#
# To make it work we have to provide a few settings values.
#
# P.S. The original idea is picked up here: https://github.com/adamesch/elgato-key-light-api

TEMPERATURE=4250 # 2900–6950K
BRIGHTNESS=33 # 1–100
DEVICES=(192.168.1.90 192.168.1.91 192.168.1.93)

# Converts a color temperature (in K) to the format Elgato Lights like (e.g., integer from 143–344)
# Warning: the actual precision is not ideal. Maybe we need to find a better way on how to convert
# the color temperatue.
function kelvin_to_elgato() {
  echo "" | awk "END {print int((987007 * $1 ^ -0.999)) }"
}

function api_url() {
  echo "http://$1:9123/elgato/lights"
}

function send_put() {
  URL=$1
  DATA=$2

  curl --location --request PUT $URL --header 'Content-Type: application/json' --data-raw $DATA
}

function on() {
  URL=$(api_url $1)
  TEMP=$(kelvin_to_elgato $2)
  BRIGHT=$3

  DATA="{\"lights\":[{\"brightness\":$BRIGHT,\"temperature\":$TEMP,\"on\":1}],\"numberOfLights\":1}"

  send_put $URL $DATA
}

function off() {
  URL=$(api_url $1)

  DATA="{\"lights\":[{\"on\":0}]}"

  send_put $URL $DATA
}

function lights_on() {
  for light in "${DEVICES[@]}"
  do
    on $light $TEMPERATURE $BRIGHTNESS
  done
}

function lights_off() {
  for light in "${DEVICES[@]}"
  do
    off $light
  done
}

# DEBUG
#
# on "192.168.1.90" $TEMPERATURE $BRIGHTNESS
# off "192.168.1.90"

log stream --predicate 'subsystem == "com.apple.UVCExtension" AND composedMessage CONTAINS "Post PowerLog"' | while read line; do
  if echo "$line" | grep -q "= On"; then
    echo "Camera has been activated"

    lights_on
  fi

  if echo "$line" | grep -q "= Off"; then
    echo "Camera has been deactivated"

    lights_off
  fi
done
