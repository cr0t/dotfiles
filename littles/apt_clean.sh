#!/bin/bash
# A little helper to manually clean Ubuntu/Debian machines after updates

UNAME=$(uname | tr "[:upper:]" "[:lower:]")

if [ "$UNAME" == "linux" ]; then
  sudo apt autoclean && sudo apt autoremove
  echo "Cleaning is done!"
else
  echo "You're not in Linux, you're in $UNAME"
fi
