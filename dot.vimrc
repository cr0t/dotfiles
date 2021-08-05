" It's a compilations and work-in-progress vim configuration file
"
" Some of the sources for inspirations are these:
"
" - https://github.com/evuez/home/blob/master/.vimrc
" - https://github.com/thoughtbot/dotfiles

" do not pretend that vim is vi
set nocompatible

" enable use of a mouse (to switch between windows, for example)
set mouse=a

" something modern again
set colorcolumn=120

" switch syntax highlighting on
syntax on

" search highlighting on
set hlsearch

" autoread file modifications
set autoread

" enable file type detection and do language-dependent indenting.
filetype plugin indent on

" search down into folders
set path+=**

" display all matching files when we tab complete
set wildmenu

" make backspace behave in a sane manner:
"
" indent  allow backspacing over autoindent
" eol     allow backspacing over line breaks (join lines)
" start   allow backspacing over the start of insert; CTRL-W and CTRL-U stop once at the start of insert.
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
set tabstop=2     " set tab width to 2 columns
set shiftwidth=2  " use 2 columns for indentation
set expandtab     " use spaces when pressing TAB

" highlight current line and current column
"set cursorline
"set cursorcolumn

" search
set incsearch  " enable incremental search
set ignorecase " make searches case insensitive
set smartcase  " make searches case sensitive if search starts with a capital

nnoremap <C-1> :buffer! 1<CR>
nnoremap <C-2> :buffer! 2<CR>

" next is mostly taken from https://github.com/thoughtbot/dotfiles
set nobackup
set nowritebackup
set noswapfile
set history=50
set autowrite

if filereadable(expand("~/.vimrc.snippets"))
  source ~/.vimrc.snippets
endif

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

if filereadable(expand("~/.vimrc.nerdtree"))
  source ~/.vimrc.nerdtree
endif

if filereadable(expand("~/.vimrc.noarrowkeys"))
  source ~/.vimrc.noarrowkeys
endif
