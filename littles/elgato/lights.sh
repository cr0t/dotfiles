#!/usr/bin/env bash
#
# Lights — switches Elgato lights in Home Assistant on/off when the macOS camera powers on/off, by
# watching the system log. No package installs required: uses only curl, sudo, and log.
#
# ## Configuration
#
# Requires ~/.local/lights.sh.conf with:
#
#     HA_BASE="http://<your_ha_instance_ip>:8123"
#     HA_TOKEN="<your_ha_token_here>"
#
# Token can be generated at http://<your_ha_instance_ip>:8123/profile/security
#
# This file contains a secret. Lock it down:
#
#     chmod 600 ~/.local/lights.sh.conf
#
# ## Log Access
#
# `log stream` needs admin privileges. To allow passwordless execution:
#
#     sudo mkdir -p /private/etc/sudoers.d
#     echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/log" | sudo tee /private/etc/sudoers.d/log-$USER
#     sudo chmod 440 /private/etc/sudoers.d/log-$USER
#
# ## Daemon usage
#
# Use as a macOS LaunchAgent (point ProgramArguments at this script's path with --watch), saved as
# ~/Library/LaunchAgents/lights.plist, then:
#
#     launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/lights.plist
#     launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/lights.plist
#
# ## Basic usage
#
#     $ lights.sh --watch
#     $ lights.sh --on
#     $ lights.sh --off

set -uo pipefail

CONFIG="$HOME/.local/lights.sh.conf"
SELFNAME=$(basename "$0")

log_info() {
  printf '%s [INFO] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}

log_error() {
  printf '%s [ERROR] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >&2
}

usage() {
  cat <<EOF
Usage: $SELFNAME --on | --off | --watch
EOF
}

load_config() {
  if [[ ! -f "$CONFIG" ]]; then
    log_error "Missing config: $CONFIG"
    exit 1
  fi

  local perms
  perms=$(stat -f '%Lp' "$CONFIG" 2>/dev/null || stat -c '%a' "$CONFIG" 2>/dev/null || echo "")

  if [[ -n "$perms" && "$perms" != "600" ]]; then
    log_error "Config $CONFIG has permissions $perms, expected 600 (run: chmod 600 $CONFIG)"
  fi

  # shellcheck source=/dev/null
  source "$CONFIG"
  : "${HA_BASE:?HA_BASE not set in $CONFIG}"
  : "${HA_TOKEN:?HA_TOKEN not set in $CONFIG}"
}

list_lamps() {
  curl -s -H "Authorization: Bearer $HA_TOKEN" "$HA_BASE/api/states" \
    | grep -o '"entity_id":"light\.elgato_[^"]*"' \
    | cut -d'"' -f4
}

turn_lamp() {
  local lamp_id="$1" action="$2" body http_code

  if [[ "$action" == "on" ]]; then
    # Uses one of the default light profiles:
    # https://github.com/home-assistant/core/blob/dev/homeassistant/components/light/light_profiles.csv
    body="{\"entity_id\":\"$lamp_id\",\"profile\":\"energize\"}"
  else
    body="{\"entity_id\":\"$lamp_id\"}"
  fi

  http_code=$(curl -s -o /dev/null -w '%{http_code}' -X POST \
    -H "Authorization: Bearer $HA_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$body" \
    "$HA_BASE/api/services/light/turn_$action") || http_code="curl_failed"

  if [[ "$http_code" == "200" ]]; then
    log_info "turning $lamp_id $action"
  else
    log_error "FAILED turning $lamp_id $action (HTTP $http_code)"
  fi
}

turn_all() {
  local action="$1"
  local pids=()

  while IFS= read -r lamp_id; do
    [[ -n "$lamp_id" ]] || continue
    turn_lamp "$lamp_id" "$action" &
    pids+=("$!")
  done < <(list_lamps)

  for pid in "${pids[@]:-}"; do
    [[ -n "$pid" ]] || continue
    wait "$pid" || log_error "background job $pid exited non-zero"
  done
}

watch() {
  log_info "$SELFNAME starts watching..."

  local predicate='subsystem == "com.apple.cmio" AND ('
  predicate+='composedMessage CONTAINS "CMIOGraphStart Calling Start" OR '
  predicate+='composedMessage CONTAINS "CMIOGraphStop Calling Stop")'

  sudo log stream --color none --style compact --predicate "$predicate" | \
    while IFS= read -r line; do
      case "$line" in
        *"CMIOGraphStart Calling Start()"*) turn_all on ;;
        *"CMIOGraphStop Calling Stop()"*) turn_all off ;;
      esac
    done
}

main() {
  load_config

  case "${1:-}" in
    --on) turn_all on ;;
    --off) turn_all off ;;
    --watch) watch ;;
    *) usage; exit 0 ;;
  esac
}

main "$@"
