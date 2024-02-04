" It's a compilations and work-in-progress vim configuration file
"
" Some of the sources for inspirations are these:
"
" - https://github.com/evuez/home/blob/master/.vimrc
" - https://github.com/thoughtbot/dotfiles
"
" Great source of options is AstroNvim's options.lua file:
"
" - https://github.com/AstroNvim/AstroNvim/blob/main/lua/astronvim/options.lua

set encoding=utf-8
set fileencoding=utf-8

" post-modernism
""set nocompatible " do not pretend that vim is vi, default since Vim 8
""set colorcolumn=120 " something modern again

" highlighting
syntax on " switch syntax highlighting on
set hlsearch " search highlighting on

" folding (zc, zo)
set foldmethod=indent
set foldlevelstart=24

" traling whitespace (non-plugin approach)
""highlight ExtraWhitespace ctermbg=red guibg=red " trailing whitespace highlighting
""match ExtraWhitespace /\s\+$/                   " (https://vim.fandom.com/wiki/Highlight_unwanted_spaces)

" csexton/trailertrash.vim plugin settings (it needs to be installed!)
highlight UnwantedTrailerTrash guibg=gray ctermbg=gray

" autoread file modifications
set autoread

" enable file type detection and do language-dependent indenting.
""filetype plugin indent on " default since Vim 8

" search down into folders (for `:find` ex command, for example)
set path+=**

" set tags for vim-fugitive (installed as plugin)
set tags^=.git/tags

" display all matching files when we tab complete
set wildmenu
set wildignorecase
set wildmode=list:longest,list:full

" more natural windows split opening (new window gets active):
" https://thoughtbot.com/blog/vim-splits-move-faster-and-more-naturally
set splitbelow
set splitright
set splitkeep=screen " (nvim 0.9+ only!) maintain code view when splitting

" support mouse and macOS system clipboard
set mouse=a
set clipboard^=unnamed,unnamedplus " cross-platform system-wide clipboard

set timeoutlen=500 ttimeoutlen=0 " improve ESC waiting time (open/close plugins or change modes blazing fast!)
set updatetime=200 " length of time to wait before triggering the plugin

" make backspace behave in a sane manner:
"
" indent  allow backspacing over autoindent
" eol     allow backspacing over line breaks (join lines)
" start   allow backspacing over the start of insert; C-W and C-U stop once at the start of insert
set backspace=indent,eol,start

" show line numbers
set number
"set relativenumber

" show the cursor position all the time
set ruler

" don't show the current mode (INSERT/VISUAL/etc.) in the statusline
set noshowmode

" display incomplete commands
set showcmd

" indentation
set tabstop=2     " set tab width to 2 columns (spaces)
set shiftwidth=2  " use 2 columns (spaces) for indentation
set softtabstop=2 " fine-tuning for inserting/deletion of whitespace (equal it to shiftwidth)
set shiftround    " round indent to multiple of 'shiftwidth'; applies to > and < commands
set expandtab     " replace TAB with spaces
set breakindent   " wrap indent to match line start
set smartindent   " smarter autoindentation
set preserveindent " preserve indent structure as much as possible

" one space, not two after '.', '?', and '!' for join command
set nojoinspaces

" highlight current line and current column
""set cursorline
""set cursorcolumn

" invisible characters (TAB, new line, etc.)
set listchars=tab:▸\ ,eol:¬ " use the same symbols as TextMate for tabstops and EOLs

" search
set incsearch  " enable incremental search
set ignorecase " make searches case insensitive
set smartcase  " make searches case sensitive if search starts with a capital

" fine-tuning
"set autowrite    " automatically :write before running commands
set hidden       " vim won't complain opening a new file, even if current buffer has unsaved changes
set history=1000 " store more items in the command/search history
set ttyfast
set lazyredraw

" let's make less garbage files on the disk
set nobackup
set nowritebackup
set noswapfile

source ~/.config/vim.d/vimrc.ftdetect    " filetype detection rules
source ~/.config/vim.d/vimrc.plugins     " list of plugins to be installed
source ~/.config/vim.d/vimrc.snippets    " list of various snippets
source ~/.config/vim.d/vimrc.howtoquit   " disturbing quit commands aliases
"source ~/.config/vim.d/vimrc.noarrowkeys " hardcore mode (without arrow keys available – to learn hjkl)

" various plugins' configurations
source ~/.config/vim.d/vimrc.airline
source ~/.config/vim.d/vimrc.obsession

" any overrides specific to the machine
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
