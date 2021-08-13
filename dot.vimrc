" It's a compilations and work-in-progress vim configuration file
"
" Some of the sources for inspirations are these:
"
" - https://github.com/evuez/home/blob/master/.vimrc
" - https://github.com/thoughtbot/dotfiles

" do not pretend that vim is vi
set nocompatible

" something modern again
set colorcolumn=120

" switch syntax highlighting on
syntax on

" search highlighting on
set hlsearch

" trailing whitespace highlighting
" https://vim.fandom.com/wiki/Highlight_unwanted_spaces
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" autoread file modifications
set autoread

" enable file type detection and do language-dependent indenting.
filetype plugin indent on

" search down into folders (for `:find` ex command, for example)
set path+=**

" display all matching files when we tab complete
set wildmenu
set wildignorecase
set wildmode=list:longest,full

" more natural windows split opening (new window gets active), https://thoughtbot.com/blog/vim-splits-move-faster-and-more-naturally
set splitbelow
set splitright

" support mouse and macOS system clipboard
set mouse=a
set ttymouse=xterm2 " works better than default, at least in iTerm2
set clipboard=unnamed

" improve ESC waiting time (open/close plugins or change modes blazing fast!)
set timeoutlen=1000 ttimeoutlen=0

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
set tabstop=2     " set tab width to 2 columns (spaces)
set shiftwidth=2  " use 2 columns (spaces) for indentation
set softtabstop=2 " fine-tuning for inserting/deletion of whitespace (equal it to shiftwidth)
set expandtab     " replace TAB with spaces

" highlight current line and current column
"set cursorline
"set cursorcolumn

" show/hide invisible characters (tab, new line, etc.)
nmap <leader>l :set list!<CR>

" use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬

" search
set incsearch  " enable incremental search
set ignorecase " make searches case insensitive
set smartcase  " make searches case sensitive if search starts with a capital

" next is mostly taken from https://github.com/thoughtbot/dotfiles
set nobackup
set nowritebackup
set noswapfile
set history=1000
set autowrite

if filereadable(expand("~/.vimconf/vimrc.snippets"))
  source ~/.vimconf/vimrc.snippets
endif

if filereadable(expand("~/.vimconf/vimrc.bundles"))
  source ~/.vimconf/vimrc.bundles
endif

if filereadable(expand("~/.vimconf/vimrc.nerdtree"))
  source ~/.vimconf/vimrc.nerdtree
endif

if filereadable(expand("~/.vimconf/vimrc.keys"))
  source ~/.vimconf/vimrc.keys
endif

" if filereadable(expand("~/.vimconf/vimrc.noarrowkeys"))
"   source ~/.vimconf/vimrc.noarrowkeys
" end
