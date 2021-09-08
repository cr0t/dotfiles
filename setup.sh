#!/bin/bash

REPO_DIR=$(cd "$(dirname $0)"; pwd -P)
FILES=$(ls -d $REPO_DIR/dot.*)
VIM_PLUG="$HOME/.vim/autoload/plug.vim"
VIM_CONF_FROM="$REPO_DIR/dot.vim.d"
VIM_CONF_TO="$HOME/.vim.d"
TMUX_CONF_FROM="$REPO_DIR/dot.tmux.d"
TMUX_CONF_TO="$HOME/.tmux.d"
FISH_CONF_FROM="$REPO_DIR/dot.config/fish/conf.d"
FISH_CONF_TO="$HOME/.config/fish/conf.d"
KITTY_CONF_FROM="$REPO_DIR/dot.config/kitty"
KITTY_CONF_TO="$HOME/.config/kitty"

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

# Wrapper to link configuration directories
function _link_directory {
  FROM=$1
  TO=$2

  echo -n "Linking $FROM directory : "

  if [ -d $TO ]; then
    _echo_error "directory $TO already exists, consider to back it up!"
    return 1
  fi

  ln -s $FROM $TO && _echo_success "done"
}

# Wrapper to unlink configuration directory
function _unlink_directory {
  echo -n "Removing $1 directory : "
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

  # ensure that parent directory exists before linking configuration
  mkdir -p ~/.config/fish

  _link_directory $VIM_CONF_FROM $VIM_CONF_TO
  _link_directory $TMUX_CONF_FROM $TMUX_CONF_TO
  _link_directory $FISH_CONF_FROM $FISH_CONF_TO
  _link_directory $KITTY_CONF_FROM $KITTY_CONF_TO

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

  _unlink_directory $KITTY_CONF_TO
  _unlink_directory $FISH_CONF_TO
  _unlink_directory $TMUX_CONF_TO
  _unlink_directory $VIM_CONF_TO
}

###

case "$1" in
  "link") _create_links;;
  "clean") _remove_links;;
  *) echo "Please, specify the task: setup.sh <link|clean>" && exit 1;;
esac
