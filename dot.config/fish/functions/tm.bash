tm() {
  local session_name

  if [[ $# -gt 0 ]]; then
    session_name="$*"
  else
    session_name=$(hostname -s | tr '[:upper:]' '[:lower:]')
  fi

  # Replace dots/spaces with dashes, truncate to 30 chars
  session_name=$(echo "$session_name" | tr ' .' '-' | cut -c1-30)

  if ! tmux has-session -t "$session_name" 2>/dev/null; then
    tmux new-session -d -s "$session_name"
  fi

  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$session_name"
  else
    tmux attach-session -t "$session_name"
  fi
}
