#!/bin/bash

REPO_DIR=$(cd "$(dirname $0)"; pwd -P)
FILES=$(ls -d $REPO_DIR/dot.*)
VIM_PLUG="$HOME/.vim/autoload/plug.vim"
TMUX_TPM="$HOME/.tmux/plugins/tpm"

# ~/.config directory might contain other applications configuration file while
# we use the system and install more utilities; and this is why we want to be
# precise in what and where we want to link
VIM_FROM="$REPO_DIR/dot.config/vim.d"
VIM_TO="$HOME/.config/vim.d"
NEOVIM_FROM="$REPO_DIR/dot.config/nvim"
NEOVIM_TO="$HOME/.config/nvim"
TMUX_FROM="$REPO_DIR/dot.config/tmux.d"
TMUX_TO="$HOME/.config/tmux.d"
FISH_CONF_FROM="$REPO_DIR/dot.config/fish/conf.d"
FISH_CONF_TO="$HOME/.config/fish/conf.d"
FISH_FUNC_FROM="$REPO_DIR/dot.config/fish/functions"
FISH_FUNC_TO="$HOME/.config/fish/functions"
KITTY_FROM="$REPO_DIR/dot.config/kitty"
KITTY_TO="$HOME/.config/kitty"
ALACRITTY_FROM="$REPO_DIR/dot.config/alacritty"
ALACRITTY_TO="$HOME/.config/alacritty"
NEWSBOAT_FROM="$REPO_DIR/dot.config/newsboat"
NEWSBOAT_TO="$HOME/.config/newsboat"

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

# Installs tmux plugin manager, if it's not installed yet
function _install_tmux_tpm {
  if [ ! -d $TMUX_TPM ]; then
    echo "Install tmux tpm..."
    # https://github.com/tmux-plugins/tpm
    git clone --quiet https://github.com/tmux-plugins/tpm $TMUX_TPM
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
  _link $TMUX_FROM $TMUX_TO
  _link $FISH_CONF_FROM $FISH_CONF_TO
  _link $FISH_FUNC_FROM $FISH_FUNC_TO
  _link $KITTY_FROM $KITTY_TO
  _link $ALACRITTY_FROM $ALACRITTY_TO
  _link $NEWSBOAT_FROM $NEWSBOAT_TO

  # extra setup – steps below will not be reverted on 'unlink' command
  _install_vim_plug
  _install_tmux_tpm

  echo "---"

  _echo_warning "BREW: Consider to run 'brew bundle --no-lock' if it's a fresh macOS installation!"
  _echo_warning "FISH: Consider to run 'cp ~/.config/fish/config.fish.example ~/.config/fish/config.fish'"
  _echo_warning "NVIM: Install or update plugins via 'vim -c PlugInstall -c PlugUpgrade -c PlugUpdate -c qall'"
  _echo_warning "TMUX: Install plugins via <prefix + I> if you're inside a tmux session"
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

  _unlink $NEWSBOAT_TO
  _unlink $ALACRITTY_TO
  _unlink $KITTY_TO
  _unlink $FISH_CONF_TO
  _unlink $FISH_FUNC_TO
  _unlink $TMUX_TO
  _unlink $VIM_TO
  _unlink $NEOVIM_TO
}

###

case "$1" in
  "link") _create_links;;
  "clean") _remove_links;;
  *) echo "Please, specify the task: setup.sh <link|clean>" && exit 1;;
esac
