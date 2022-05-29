" It's a compilations and work-in-progress vim configuration file
"
" Some of the sources for inspirations are these:
"
" - https://github.com/evuez/home/blob/master/.vimrc
" - https://github.com/thoughtbot/dotfiles

set encoding=utf-8

" post-modernism
set nocompatible    " do not pretend that vim is vi
"set colorcolumn=120 " something modern again

" highlighting
syntax on                                       " switch syntax highlighting on
set hlsearch                                    " search highlighting on
highlight ExtraWhitespace ctermbg=red guibg=red " trailing whitespace highlighting
match ExtraWhitespace /\s\+$/                   " (https://vim.fandom.com/wiki/Highlight_unwanted_spaces)

" autoread file modifications
set autoread

" enable file type detection and do language-dependent indenting.
filetype plugin indent on

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

" support mouse and macOS system clipboard
set mouse=a
"set ttymouse=xterm2 " works better than default, at least in iTerm2
set clipboard=unnamed

" improve ESC waiting time (open/close plugins or change modes blazing fast!)
set timeoutlen=1000 ttimeoutlen=0

" make backspace behave in a sane manner:
"
" indent  allow backspacing over autoindent
" eol     allow backspacing over line breaks (join lines)
" start   allow backspacing over the start of insert; C-W and C-U stop once at the start of insert
set backspace=indent,eol,start

" show line numbers
set number
set relativenumber

" show the cursor position all the time
set ruler

" display incomplete commands
set showcmd

" always display the status line
set laststatus=2

" indentation
set tabstop=2     " set tab width to 2 columns (spaces)
set shiftwidth=2  " use 2 columns (spaces) for indentation
set softtabstop=2 " fine-tuning for inserting/deletion of whitespace (equal it to shiftwidth)
set shiftround    " round indent to multiple of 'shiftwidth'; applies to > and < commands
set expandtab     " replace TAB with spaces

" one space, not two after '.', '?', and '!' for join command
set nojoinspaces

" highlight current line and current column
"set cursorline
"set cursorcolumn

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

" let's make less garbage files on the disk
set nobackup
set nowritebackup
set noswapfile

" filetype detection rules
if filereadable(expand("~/.config/vim.d/vimrc.ftdetect"))
  source ~/.config/vim.d/vimrc.ftdetect
endif

" list of plugins to be installed
if filereadable(expand("~/.config/vim.d/vimrc.bundles"))
  source ~/.config/vim.d/vimrc.bundles
endif

" list of various snippets
if filereadable(expand("~/.config/vim.d/vimrc.snippets"))
  source ~/.config/vim.d/vimrc.snippets
endif

" keyboard shortcuts and settings
if filereadable(expand("~/.config/vim.d/vimrc.keys"))
  source ~/.config/vim.d/vimrc.keys
endif

" hardcore mode (without arrow keys available – to learn hjkl)
"if filereadable(expand("~/.config/vim.d/vimrc.noarrowkeys"))
"  source ~/.config/vim.d/vimrc.noarrowkeys
"endif

" any overrides specific to the machine
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

" below are configuration file for the plugins

if filereadable(expand("~/.config/vim.d/vimrc.fzf"))
  source ~/.config/vim.d/vimrc.fzf
endif

if filereadable(expand("~/.config/vim.d/vimrc.nerdtree"))
  source ~/.config/vim.d/vimrc.nerdtree
endif

if filereadable(expand("~/.config/vim.d/vimrc.airline"))
  source ~/.config/vim.d/vimrc.airline
endif

if filereadable(expand("~/.config/vim.d/vimrc.coc"))
  source ~/.config/vim.d/vimrc.coc
endif
