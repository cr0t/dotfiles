#!/bin/bash

REPO_DIR=$(cd "$(dirname $0)"; pwd -P)
FILES=$(ls -d $REPO_DIR/dot.*)
VIM_PLUG="$HOME/.vim/autoload/plug.vim"

# ~/.config directory might contain other applications configuration file while
# we use the system and install more utilities; and this is why we want to be
# precise in what and where we want to link
VIM_FROM="$REPO_DIR/dot.config/vim.d"
VIM_TO="$HOME/.config/vim.d"
VIM_COC_FROM="$REPO_DIR/dot.config/vim.d/coc-settings.json"
VIM_COC_TO="$HOME/.vim/coc-settings.json"
NEOVIM_FROM="$REPO_DIR/dot.config/nvim"
NEOVIM_TO="$HOME/.config/nvim"
TMUX_FROM="$REPO_DIR/dot.config/tmux.d"
TMUX_TO="$HOME/.config/tmux.d"
FISH_FROM="$REPO_DIR/dot.config/fish/conf.d"
FISH_TO="$HOME/.config/fish/conf.d"
KITTY_FROM="$REPO_DIR/dot.config/kitty"
KITTY_TO="$HOME/.config/kitty"

# Colors
RED='\033[0;31m'
GRN='\033[0;32m'
YEL='\033[0;33m'
CLR='\033[0m'

function _echo_error {
  echo -e "${RED}$1${CLR}"
}

function _echo_warning {
  echo -e "${YEL}$1${CLR}"
}

function _echo_success {
  echo -e "${GRN}$1${CLR}"
}

# Replaces 'dot.' with a simple '.' in the given parameter
function _linkpath {
  BASENAME=$(basename $1)
  NO_DOT="${BASENAME/dot./.}"
  echo "$HOME/$NO_DOT"
}

# Wrapper to make a soft link
function _link {
  FROM=$1
  TO=$2

  echo -n "Linking $FROM : "

  if [ -d $TO ]; then
    _echo_error "$TO already exists, consider to back it up!"
    return 1
  fi

  ln -s $FROM $TO && _echo_success "done"
}

# Wrapper to unlink configuration directory or file
function _unlink {
  echo -n "Removing $1 : "
  rm $1 && _echo_success "done"
}

# Installs vim-plug package manager, if it's not installed yet
function _install_vim_plug {
  if [ ! -f $VIM_PLUG ]; then
    echo "Install vim-plug..."
    # https://github.com/junegunn/vim-plug
    curl -fLo $VIM_PLUG --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
}

# 1. Links regular dot.* files from the repository to their counterparts
# 2. Runs vim-plug installation
# 3. Runs fish configuration linking process
function _create_links {
  for f in $FILES; do
    if [ ! -d $f ]; then
      LINKPATH=$(_linkpath $f)
      echo -n "Linking $f to $LINKPATH : "
      LN_OUTPUT=$(ln -s $f $LINKPATH 2>&1)

      if [ $? -eq 0 ]; then
        _echo_success "done"
      else
        _echo_error "already exists"
      fi
    fi
  done

  # ensure that parent directories exist before linking configuration
  mkdir -p ~/.config/fish
  mkdir -p ~/.vim

  _link $NEOVIM_FROM $NEOVIM_TO
  _link $VIM_FROM $VIM_TO
  _link $VIM_COC_FROM $VIM_COC_TO
  _link $TMUX_FROM $TMUX_TO
  _link $FISH_FROM $FISH_TO
  _link $KITTY_FROM $KITTY_TO

  _install_vim_plug

  echo && _echo_warning "NOTE: Consider to run brew_fre.sh if it's a fresh macOS installation!"
}

# 1. Removes links from regular dot.* files
# 2. Runs fish configuration clean up process
function _remove_links {
  for f in $FILES; do
    if [ ! -d $f ]; then
      LINKPATH=$(_linkpath $f)
      echo -n "Removing $LINKPATH : "
      rm $LINKPATH && _echo_success "done"
    fi
  done

  _unlink $KITTY_TO
  _unlink $FISH_TO
  _unlink $TMUX_TO
  _unlink $VIM_COC_TO
  _unlink $VIM_TO
  _unlink $NEOVIM_TO
}

###

case "$1" in
  "link") _create_links;;
  "clean") _remove_links;;
  *) echo "Please, specify the task: setup.sh <link|clean>" && exit 1;;
esac
