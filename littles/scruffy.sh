#!/usr/bin/env bash

# Scruffy Scruffington: "Scruffy's gonna clean up them processes. Yup."
#
# This script shall be used as a wrapper to execute long-running processes via Port to avoid
# leaving orphaned zombie processes in case of BEAM abnormal termination. Read more:
#
# https://hexdocs.pm/elixir/Port.html#module-zombie-operating-system-processes

# Start the program in the background
exec "$@" &
pid1=$!

# Silence warnings from here on
exec >/dev/null 2>&1

# Read from stdin in the background and
# kill running program when stdin closes
exec 0<&0 $(
  while read; do :; done
  kill -KILL $pid1
) &
pid2=$!

# Clean up
wait $pid1
ret=$?
kill -KILL $pid2
exit $ret
