#!/bin/bash

REPO_DIR=$(cd "$(dirname $0)"; pwd -P)
FILES=$(ls -d $REPO_DIR/dot.*)
VIM_PLUG="$HOME/.vim/autoload/plug.vim"
FISH_CONF_FROM="$REPO_DIR/dot.config/fish/conf.d"
FISH_CONF_TO="$HOME/.config/fish/conf.d"

function _linkpath {
  BASENAME=$(basename $1)
  NO_DOT="${BASENAME/dot./.}"
  echo "$HOME/$NO_DOT"
}

function _install_vim_plug {
  if [ ! -f $VIM_PLUG ]; then
    echo "Install vim-plug..."
    # https://github.com/junegunn/vim-plug
    curl -fLo $VIM_PLUG --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
}

function _link_fish_conf {
  echo -n "Linking $FISH_CONF_FROM directory : "

  if [ -d $FISH_CONF_TO ]; then
    echo "directory $FISH_CONF_TO already exists, consider to back it up!"
    exit 1
  fi

  ln -s $FISH_CONF_FROM $FISH_CONF_TO && echo "done"
}

function _unlink_fish_conf {
  echo -n "Removing $FISH_CONF_FROM directory : "
  rm $FISH_CONF_TO && echo "done"
}

function _create_links {
  for f in $FILES; do
    if [ ! -d $f ]; then
      LINKPATH=$(_linkpath $f)
      echo -n "Linking $f to $LINKPATH : "
      ln -s $f $LINKPATH && echo "done"
    fi
  done

  _install_vim_plug
  _link_fish_conf
}

function _remove_links {
  for f in $FILES; do
    if [ ! -d $f ]; then
      LINKPATH=$(_linkpath $f)
      echo -n "Removing $LINKPATH : "
      rm $LINKPATH && echo "done"
    fi
  done

  _unlink_fish_conf
}

while [ -n "$1" ]; do
  case "$1" in
    link) _create_links;;
    clean) _remove_links;;
  esac
  shift
done
