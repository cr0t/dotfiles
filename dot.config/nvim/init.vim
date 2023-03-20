set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" Plugins' settings (when in Lua)
source ~/.config/nvim/telescope.lua

" colorscheme kanagawa
colorscheme nightfox
