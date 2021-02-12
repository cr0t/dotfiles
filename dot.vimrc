" do not pretend that vim is vi
set nocompatible

" something modern again
set colorcolumn=120

" add some colors to the screen
syntax enable
filetype plugin on
filetype indent on

" search down into folders
set path+=**

" display all matching files when we tab complete
set wildmenu

" indentation
"set autoindent
"set cindent
"set smartindent
set tabstop=2     " set tab width to 2 columns
set shiftwidth=2  " use 2 columns for indentation
set expandtab     " use spaces when pressing TAB

nnoremap <C-1> :buffer! 1<CR>
nnoremap <C-2> :buffer! 2<CR>

" hardmode... no arrow keys!
nnoremap <Left> <Nop>
vnoremap <Left> <Nop>
inoremap <Left> <Nop>
nnoremap <Down> <Nop>
vnoremap <Down> <Nop>
inoremap <Down> <Nop>
nnoremap <Up> <Nop>
vnoremap <Up> <Nop>
inoremap <Up> <Nop>
nnoremap <Right> <Nop>
vnoremap <Right> <Nop>
inoremap <Right> <Nop>

" next is taken from https://github.com/thoughtbot/dotfiles
set backspace=2   " Backspace deletes like most programs in insert mode
set nobackup
set nowritebackup
set noswapfile
set history=50
set ruler         " show the cursor position all the time
set showcmd       " display incomplete commands
set incsearch     " do incremental searching
set laststatus=2  " Always display the status line
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
