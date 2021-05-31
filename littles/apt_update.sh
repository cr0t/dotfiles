#!/bin/bash
# A little helper to manually update Ubuntu/Debian machines

UNAME=$(uname | tr "[:upper:]" "[:lower:]")

if [ "$UNAME" == "linux" ]; then
  sudo apt update && sudo apt dist-upgrade -y
else
  echo "You're not in Linux, you're in $UNAME"
fi
