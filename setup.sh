#!/bin/bash

REPO_DIR=$(dirname $0)
FILES=$(ls $REPO_DIR/dot.*)
VIM_PLUG=~/.vim/autoload/plug.vim

function _linkpath {
  BASENAME=$(basename $1)
  NO_DOT="${BASENAME/dot./.}"
  echo "$HOME/$NO_DOT"
}

function _link_it {
  for f in $FILES; do
    LINKPATH=$(_linkpath $f)
    echo -n "Linking $f to $LINKPATH : "
    ln -s $f $LINKPATH && echo "done"
  done

  if [ ! -f $VIM_PLUG ]; then
    echo "Install vim-plug..."
    # https://github.com/junegunn/vim-plug
    curl -fLo $VIM_PLUG --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
}

function _clean_it {
  for f in $FILES; do
    LINKPATH=$(_linkpath $f)
    echo -n "Removing $LINKPATH : "
    rm $LINKPATH && echo "done"
  done
}

while [ -n "$1" ]; do
  case "$1" in
    clean) _clean_it;;
    link) _link_it;;
  esac
  shift
done
