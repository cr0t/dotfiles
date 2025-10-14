#!/bin/bash

# There is an issue with M-series Macs using Thunderbolt/USB-C Ethernet adapters
# after wake from sleep. We experienced the issue with Elgato Thunderbolt 3 Dock
# and CalDigit TS5 Plus. The problem can be solved differently, but we prefer
# to run a manual script.
#
# To skip the sudo password prompt we can adjust sudoers files.
#
# Run: sudo visudo -f /etc/sudoers.d/netreset
#
# Add this to the file: your_username ALL = (ALL) NOPASSWD: /sbin/ifconfig

set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This script requires macOS" >&2
  exit 1
fi

if [[ -z "${1:-}" ]]; then
  echo "Usage: $0 <interface>"
  echo "Example: $0 en0"
  echo ""
  echo "Available interfaces:"
  echo ""

  networksetup -listallhardwareports | awk '/Hardware Port:/ {port=$0; sub(/Hardware Port: /, "", port); sub(/ \(.*\)/, "", port)} /Device:/ {device=$2; ip=""; cmd="ipconfig getifaddr " device " 2>/dev/null"; cmd | getline ip; close(cmd); print device ", " port (ip != "" ? " [" ip "]" : "")}'

  exit 1
fi

INTERFACE="$1"

# Check if interface exists
if ! ifconfig "$INTERFACE" &> /dev/null; then
  echo "Error: Interface $INTERFACE not found" >&2
  exit 1
fi

echo "Resetting interface: $INTERFACE"
sudo ifconfig "$INTERFACE" down
sleep 1
sudo ifconfig "$INTERFACE" up
echo "Done. Interface $INTERFACE reset."
