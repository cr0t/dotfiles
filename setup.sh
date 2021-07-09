#!/bin/bash

REPO_DIR=$(cd "$(dirname $0)"; pwd -P)
FILES=$(ls -d $REPO_DIR/dot.*)
VIM_PLUG="$HOME/.vim/autoload/plug.vim"
VIM_SNIPPETS_FROM="$REPO_DIR/dot.vimsnippets"
VIM_SNIPPETS_TO="$HOME/.vimsnippets"
FISH_CONF_FROM="$REPO_DIR/dot.config/fish/conf.d"
FISH_CONF_TO="$HOME/.config/fish/conf.d"

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

# Installs vim-plug package manager, if it's not installed yet
function _install_vim_plug {
  if [ ! -f $VIM_PLUG ]; then
    echo "Install vim-plug..."
    # https://github.com/junegunn/vim-plug
    curl -fLo $VIM_PLUG --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
}

# Links ~/.vimsnippets directory
function _link_vim_snippets {
  echo -n "Linking $VIM_SNIPPETS_FROM directory : "

  if [ -d $VIM_SNIPPETS_TO ]; then
    _echo_error "directory $VIM_SNIPPETS_TO already exists, consider to back it up!"
    return 1
  fi

  ln -s $VIM_SNIPPETS_FROM $VIM_SNIPPETS_TO && _echo_success "done"
}

# Unlinks ~/.vimsnippets directory
function _unlink_vim_snippets {
  echo -n "Removing $VIM_SNIPPETS_TO directory : "
  rm $VIM_SNIPPETS_TO && _echo_success "done"
}

# Links ~/.config/fish/conf.d directory
function _link_fish_conf {
  echo -n "Linking $FISH_CONF_FROM directory : "

  if [ -d $FISH_CONF_TO ]; then
    _echo_error "directory $FISH_CONF_TO already exists, consider to back it up!"
    return 1
  fi

  NO_CONF_D="${FISH_CONF_TO/conf.d/}"
  mkdir -p $NO_CONF_D && ln -s $FISH_CONF_FROM $FISH_CONF_TO && _echo_success "done"
}

# Unlinks ~/config.d/fish/conf.d directory
function _unlink_fish_conf {
  echo -n "Removing $FISH_CONF_FROM directory : "
  rm $FISH_CONF_TO && _echo_success "done"
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

  _install_vim_plug
  _link_vim_snippets
  _link_fish_conf

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

  _unlink_vim_snippets
  _unlink_fish_conf
}

###

case "$1" in
  "link") _create_links;;
  "clean") _remove_links;;
  *) echo "Please, specify the task: setup.sh <link|clean>" && exit 1;;
esac
