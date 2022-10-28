#!/bin/bash
#
# Concatenates nginx access log files for the given domain (as first argument),
# processes via GoAccess and shows the results in terminal.

if [ ! $1 ]; then
  echo "Please, provide a domain name for access log files, e.g.: $0 lexin.mobi"
  exit 1
fi

DOMAIN=$1

sudo sh -c "cat /var/log/nginx/$DOMAIN-access.log | cat /var/log/nginx/$DOMAIN-access.log.1 | zcat /var/log/nginx/$DOMAIN-access.log.*.gz | goaccess -c --log-format=COMBINED -"
