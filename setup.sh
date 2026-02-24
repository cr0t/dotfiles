#!/bin/bash

set -euo pipefail

REPO_DIR=$(cd "$(dirname "$0")"; pwd -P)

# dot.config/* subdirectories to link (source relative to REPO_DIR->dest relative to HOME)
# Convention: path under dot.config/ maps to ~/.config/ by stripping the 'dot.' prefix
CONFIG_DIRS=(
  "dot.config/nvim"
  "dot.config/vim.d"
  "dot.config/tmux.d"
  "dot.config/fish/conf.d"
  "dot.config/fish/functions"
  "dot.config/karabiner"
  "dot.config/kitty"
  "dot.config/alacritty"
  "dot.config/newsboat"
)

VIM_PLUG="$HOME/.vim/autoload/plug.vim"
TMUX_TPM="$HOME/.tmux/plugins/tpm"

# Colors
RED='\033[0;31m'
GRN='\033[0;32m'
YEL='\033[0;33m'
CLR='\033[0m'

_error()   { echo -e "${RED}$1${CLR}"; }
_warning() { echo -e "${YEL}$1${CLR}"; }
_success() { echo -e "${GRN}$1${CLR}"; }

# Derives the destination path for a dot.config/* entry:
# dot.config/nvim -> $HOME/.config/nvim
_dest() {
  local src="$1"            # e.g. "dot.config/nvim"
  local rel="${src/dot./.}" # e.g. ".config/nvim"

  echo "$HOME/$rel"         # e.g. "/home/user/.config/nvim"
}

# Creates a symlink FROM → TO, with safety checks
_link() {
  local from="$1" to="$2"

  echo -n "Linking $from → $to : "

  if [ -e "$to" ] || [ -L "$to" ]; then
    _error "already exists, consider backing it up!"

    return 1
  fi

  ln -s "$from" "$to" && _success "done"
}

# Removes a symlink
_unlink() {
  echo -n "Removing $1 : "
  unlink "$1" && _success "done"
}

_install_vim_plug() {
  if [ ! -f "$VIM_PLUG" ]; then
    echo "Installing vim-plug..."

    curl -fLo "$VIM_PLUG" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
}

_install_tmux_tpm() {
  if [ ! -d "$TMUX_TPM" ]; then
    echo "Installing tmux tpm..."

    git clone --quiet https://github.com/tmux-plugins/tpm "$TMUX_TPM"
  fi
}

_create_links() {
  # Link top-level dot.* files (e.g. dot.bashrc → ~/.bashrc)
  for f in "$REPO_DIR"/dot.*; do
    [ -d "$f" ] && continue

    local dest="$HOME/.${f##*/dot.}"

    echo -n "Linking $f → $dest : "

    if ln -s "$f" "$dest" 2>/dev/null; then
      _success "done"
    else
      _error "already exists"
    fi
  done

  # Link dot.config/* directories
  for src in "${CONFIG_DIRS[@]}"; do
    local dest=$(_dest "$src")

    mkdir -p "$(dirname "$dest")"

    _link "$REPO_DIR/$src" "$dest"
  done

  # Extra setup (not reverted by 'clean')
  mkdir -p "$HOME/.vim"

  _install_vim_plug
  _install_tmux_tpm

  echo "---"

  _warning "BREW: Consider running 'brew bundle --no-lock' on a fresh macOS install"
  _warning "FISH: Consider running 'cp ~/.config/fish/config.fish.example ~/.config/fish/config.fish'"
  _warning "NVIM: Install plugins via 'vim -c PlugInstall -c PlugUpgrade -c PlugUpdate -c qall'"
  _warning "NVIM: Install plugins via 'nvim --headless \"+Lazy! sync\" +qa && nvim --headless \"+MasonUpdate\" +qa'"
  _warning "TMUX: Install plugins via <prefix + I> inside a tmux session"
}

_remove_links() {
  # Remove top-level dot.* symlinks
  for f in "$REPO_DIR"/dot.*; do
    [ -d "$f" ] && continue

    local dest="$HOME/.${f##*/dot.}"

    echo -n "Removing $dest : "

    unlink "$dest" && _success "done"
  done

  # Remove dot.config/* symlinks (reverse order for cleanliness)
  for (( i=${#CONFIG_DIRS[@]}-1; i>=0; i-- )); do
    _unlink "$(_dest "${CONFIG_DIRS[$i]}")"
  done
}

case "${1:-}" in
  link)  _create_links ;;
  clean) _remove_links ;;
  *)     echo "Usage: setup.sh <link|clean>" && exit 1 ;;
esac
