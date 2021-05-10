#!/bin/bash
# A little helper with the list of utilities and programs I like to install via Homebrew on a fresh macOS.

if ! command -v brew &> /dev/null; then
  echo "Homebrew is not available, install it first. See https://brew.sh/"
  exit 1
fi

UTILITIES=(ack gping htop mtr tree)
PACKAGES=(ansible elixir exiftool ffmpeg fish git imagemagick node rbenv-gemset tmux yarn)

_brew_install() {
  while (($#)); do
    brew install --quiet $1
    shift
  done
}

brew update

_brew_install ${UTILITIES[*]}
_brew_install ${PACKAGES[*]}

