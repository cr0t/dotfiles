#!/bin/bash

# Remove all the temp Neovim files: cache, installed plugins, and other stuff).
#
# It's useful for experiments and trying new big Neovim setups.

rm -rf ~/.cache/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim

echo "Consider to cleanup ~/.config/nvim"
echo "Good luck!"
