set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

source ~/.vimrc

" colorscheme kanagawa
colorscheme nightfox

" https://www.jmaguire.tech/posts/treesitter_folding/ (zc, zo, zO, etc.)
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()

" nvim-treesitter configuration
lua << EOF
require('nvim-treesitter.configs').setup({
  ensure_installed = {
    "c", "elixir", "erlang", "fish", "haskell", "help", "javascript", "lua", "query", "ruby", "typescript", "vim"
  },
  highlight = {
    enable = false, -- test this later...
  }
})
EOF
