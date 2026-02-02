#!/usr/bin/env bash

# Scruffy Scruffington mumbles, "Scruffy's gonna clean up those processes. Yup..."
#
# This script shall be used as a wrapper to execute long-running processes via Port to avoid
# leaving orphaned zombie processes in case of BEAM abnormal termination. Read more:
#
# This script serves as a wrapper to execute long-running processes via Port and prevents creation
# of orphaned zombie processes in the event of an abnormal termination of the BEAM VM. For further
# information, read:
#
# https://hexdocs.pm/elixir/Port.html#module-orphan-operating-system-processes

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
