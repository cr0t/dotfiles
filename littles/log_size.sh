#!/bin/bash
#
# Prints access_log (nginx, in particular) with indicator chart bars under each
# request line to show the site of the data transfer.
#
# Origin: https://twitter.com/climagic/status/1451561239876878350

ACCESS_LOG=$1

if [ ! $1 ]; then
  echo "Please, provide an access log filename"
  exit 1
fi

awk -v cols=$(tput cols) '{e=int(log($10)*5); print("\x1b[42m" substr($0, 1, e) "\x1b[0m" substr($0, e+1) )}' $ACCESS_LOG | less -SR
