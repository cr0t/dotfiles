set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" Plugins' settings (when in Lua)
source ~/.config/nvim/nvim-tree.lua
source ~/.config/nvim/telescope.lua
source ~/.config/nvim/treesitter.lua " disable it if indent behaves crazy...
source ~/.config/nvim/nvim-lspconfig.lua
source ~/.config/nvim/nvim-cmp.lua

" colorscheme kanagawa
colorscheme nightfox
