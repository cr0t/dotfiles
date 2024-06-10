set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" set termguicolors (also needed by nvim-tree to highlight groups)
set termguicolors

" Neovide-specific settings
source ~/.config/nvim/neovide.lua

" Plugins' settings (when in Lua)
source ~/.config/nvim/langmapper.lua
source ~/.config/nvim/nvim-tree.lua
source ~/.config/nvim/telescope.lua
source ~/.config/nvim/treesitter.lua " disable it if indent behaves crazy...
source ~/.config/nvim/mason-lspconfig.lua
source ~/.config/nvim/nvim-cmp.lua
source ~/.config/nvim/keys.lua

" colorscheme kanagawa
" colorscheme nightfox
" colorscheme terafox
colorscheme tokyonight-moon
