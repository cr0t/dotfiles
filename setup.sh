#!/usr/bin/env bash
#
# cr0t's dotfiles installer.
#
# Usage: setup.sh <command> [options]
#
# Commands:
#   link     Symlink dotfiles into $HOME (skips anything that already exists)
#   status   Show state of every entry: ok | missing | conflict
#   diff     Show diffs between existing files and the ones in this repo
#   clean    Remove symlinks created by this repo (never touches real files)
#
# Options:
#   -f, --force     (link) Back up conflicting files, then replace them
#   -n, --dry-run   Print what would happen without changing anything
#
# Backups go to $DOTFILES_BACKUP_DIR (default: ~/.dotfiles-backup/<timestamp>/),
# preserving their path relative to $HOME, so restoring is a plain `mv`.

set -euo pipefail

REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
BACKUP_DIR="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)}"

# Directories under dot.config/ to link as a whole.
# Convention: strip the 'dot.' prefix -> dot.config/nvim => ~/.config/nvim
CONFIG_DIRS=(
  "dot.config/alacritty"
  "dot.config/fish/conf.d"
  "dot.config/fish/functions"
  "dot.config/karabiner"
  "dot.config/kitty"
  "dot.config/mise"
  "dot.config/newsboat"
  "dot.config/nvim"
  "dot.config/tmux.d"
  "dot.config/vim.d"
)

VIM_PLUG="$HOME/.vim/autoload/plug.vim"
TMUX_TPM="$HOME/.tmux/plugins/tpm"

FORCE=0
DRY_RUN=0
BACKED_UP=0

# Colors (only when stdout is a terminal)
if [ -t 1 ]; then
  RED=$'\033[0;31m' GRN=$'\033[0;32m' YEL=$'\033[0;33m' CLR=$'\033[0m'
else
  RED='' GRN='' YEL='' CLR=''
fi

_error() { printf '%s%s%s\n' "$RED" "$1" "$CLR"; }
_warning() { printf '%s%s%s\n' "$YEL" "$1" "$CLR"; }

# One output line: <label padded to 9> <path>  (note)
_row() { printf '%s%-9s%s %s%s\n' "$2" "$1" "$CLR" "$3" "${4:+  ($4)}"; }

# Runs a command unless in dry-run mode
_run() {
  if ((DRY_RUN)); then return 0; fi
  "$@"
}

# Fills SRCS/DESTS with parallel arrays of (repo path, target path)
_collect() {
  SRCS=() DESTS=()
  local f src

  # Top-level dot.* files (dot.bashrc -> ~/.bashrc)
  for f in "$REPO_DIR"/dot.*; do
    [ -f "$f" ] || continue
    SRCS+=("$f")
    DESTS+=("$HOME/.${f##*/dot.}")
  done

  # dot.config/* directories
  for src in "${CONFIG_DIRS[@]}"; do
    SRCS+=("$REPO_DIR/$src")
    DESTS+=("$HOME/.${src#dot.}")
  done
}

# ok       = already our symlink
# missing  = nothing there
# conflict = anything else (real file/dir, foreign or broken symlink)
_state() {
  local from="$1" to="$2"

  if [ -L "$to" ]; then
    if [ "$(readlink "$to")" = "$from" ]; then echo ok; else echo conflict; fi
  elif [ -e "$to" ]; then
    echo conflict
  else
    echo missing
  fi
}

# Moves $1 into the backup dir, keeping its path relative to $HOME
_backup() {
  local to="$1"
  local target="$BACKUP_DIR/${to#"$HOME"/}"

  _run mkdir -p "$(dirname "$target")"
  _run mv "$to" "$target"
  BACKED_UP=$((BACKED_UP + 1))
}

_link() {
  local from="$1" to="$2" label=linked color="$GRN" note=""

  if [ ! -e "$from" ]; then
    _row error "$RED" "$to" "source missing in repo"
    return 1
  fi

  case "$(_state "$from" "$to")" in
  ok)
    _row ok "$GRN" "$to"
    return 0
    ;;
  conflict)
    if ! ((FORCE)); then
      _row skipped "$RED" "$to" "exists; see 'diff', or use --force"
      return 1
    fi
    _backup "$to"
    label=replaced color="$YEL" note="old one backed up"
    ;;
  esac

  _run mkdir -p "$(dirname "$to")"
  _run ln -s "$from" "$to"
  _row "$label" "$color" "$to" "$note"
}

_unlink() {
  local from="$1" to="$2"

  case "$(_state "$from" "$to")" in
  ok)
    _run rm "$to"
    _row removed "$GRN" "$to"
    ;;
  missing) _row missing "$YEL" "$to" ;;
  conflict) _row kept "$YEL" "$to" "not a link to this repo" ;;
  esac
}

# Installs a helper if absent; failures are warnings, not fatal
_install_vim_plug() {
  if [ -f "$VIM_PLUG" ]; then
    _row ok "$GRN" "$VIM_PLUG"
    return 0
  fi

  if _run curl -fsLo "$VIM_PLUG" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; then
    _row installed "$GRN" "$VIM_PLUG"
  else
    _row error "$RED" "$VIM_PLUG" "download failed"
  fi
}

_install_tmux_tpm() {
  if [ -d "$TMUX_TPM" ]; then
    _row ok "$GRN" "$TMUX_TPM"
    return 0
  fi

  if _run git clone --quiet https://github.com/tmux-plugins/tpm "$TMUX_TPM"; then
    _row installed "$GRN" "$TMUX_TPM"
  else
    _row error "$RED" "$TMUX_TPM" "clone failed"
  fi
}

cmd_link() {
  local i failed=0
  _collect

  for i in "${!SRCS[@]}"; do
    _link "${SRCS[$i]}" "${DESTS[$i]}" || failed=$((failed + 1))
  done

  # Extra setup (not reverted by 'clean'); failures here are non-fatal
  _run mkdir -p "$HOME/.vim"
  _install_vim_plug
  _install_tmux_tpm

  echo "---"
  ((BACKED_UP)) && _warning "Backed up $BACKED_UP item(s) to $BACKUP_DIR"
  ((failed)) && _error "$failed item(s) skipped; run '$0 diff' to inspect, '$0 link --force' to replace"

  _warning "BREW: Consider running 'brew bundle --no-lock' on a fresh macOS install"
  _warning "FISH: Consider running 'cp $REPO_DIR/dot.config/fish/config.fish.example ~/.config/fish/config.fish'"
  _warning "VIM:  Install plugins via 'vim -c PlugInstall -c PlugUpgrade -c PlugUpdate -c qall'"
  _warning "NVIM: Install plugins via 'nvim --headless \"+Lazy! sync\" +qa && nvim --headless \"+MasonUpdate\" +qa'"
  _warning "TMUX: Install plugins via <prefix + I> inside a tmux session"
  _warning "MISE: Install tools via 'env KERL_BUILD_DOCS=yes KERL_CONFIGURE_OPTIONS=\"--without-javac\" mise install --include-lazy'"

  [ "$failed" -eq 0 ]
}

cmd_clean() {
  local i
  _collect

  # Reverse order for cleanliness
  for ((i = ${#SRCS[@]} - 1; i >= 0; i--)); do
    _unlink "${SRCS[$i]}" "${DESTS[$i]}"
  done
}

cmd_status() {
  local i state
  _collect

  for i in "${!SRCS[@]}"; do
    state=$(_state "${SRCS[$i]}" "${DESTS[$i]}")
    case "$state" in
    ok) _row "$state" "$GRN" "${DESTS[$i]}" ;;
    missing) _row "$state" "$YEL" "${DESTS[$i]}" ;;
    conflict) _row "$state" "$RED" "${DESTS[$i]}" ;;
    esac
  done
}

cmd_diff() {
  local i
  _collect

  for i in "${!SRCS[@]}"; do
    [ "$(_state "${SRCS[$i]}" "${DESTS[$i]}")" = conflict ] || continue

    echo "=== ${DESTS[$i]}"
    [ -L "${DESTS[$i]}" ] && echo "(symlink → $(readlink "${DESTS[$i]}"))"

    # '-' side = what's on disk now, '+' side = what this repo would install
    diff -ruN "${DESTS[$i]}" "${SRCS[$i]}" 2>&1 || true
    echo
  done
}

usage() {
  sed -n '3,19p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit 1
}

cmd="${1:-}"
[ $# -gt 0 ] && shift

for arg in "$@"; do
  case "$arg" in
  -f | --force) FORCE=1 ;;
  -n | --dry-run) DRY_RUN=1 ;;
  *) usage ;;
  esac
done

((DRY_RUN)) && _warning "Dry run: no changes will be made"

case "$cmd" in
link) cmd_link ;;
clean) cmd_clean ;;
status) cmd_status ;;
diff) cmd_diff ;;
*) usage ;;
esac
