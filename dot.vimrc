" ...work-in-progress Vim/Neovim configuration file
"
" Some of the sources for inspirations:
"
" - https://github.com/evuez/home/blob/master/.vimrc
" - https://github.com/thoughtbot/dotfiles

" Neovim has UTF-8 by default, but for Vim it's not always like that
set encoding=utf-8

" folding (zc, zo)
set foldmethod=indent
set foldlevelstart=24

" search down into folders (for `:find` ex command, for example)
set path+=**

" display all matching files when we tab complete
set wildmenu
set wildignorecase
set wildmode=list:longest,list:full

" more natural windows split opening (new window gets active):
" https://thoughtbot.com/blog/vim-splits-move-faster-and-more-naturally
set splitbelow
set splitright
set splitkeep=screen " (nvim 0.9+ only!) maintain code view when splitting

" make backspace behave in a sane manner:
"
" indent  allow backspacing over autoindent
" eol     allow backspacing over line breaks (join lines)
" start   allow backspacing over the start of insert; C-W and C-U stop once at the start of insert
set backspace=indent,eol,start

" UI/UX
syntax on                          " switch syntax highlighting on
set termguicolors                  " allows 24-bit color (e.g., nvim-tree needs that for highlighting)
set number                         " show line numbers
set ruler                          " show the cursor position all the time
set noshowmode                     " don't show the current mode (INSERT/VISUAL/etc.) in the statusline
set showcmd                        " display incomplete commands
set nojoinspaces                   " one space, not two after '.', '?', and '!' for join command
set listchars=tab:▸\ ,eol:¬        " invisible characters (TAB, new line, etc.); same symbols as in TextMate
set mouse=a                        " support mouse and macOS system clipboard
set clipboard^=unnamed,unnamedplus " cross-platform system-wide clipboard

" 'theory of relativity'
set timeoutlen=200 ttimeoutlen=0 " improve ESC waiting time (open/close plugins or change modes blazing fast!)
set updatetime=200               " used for CursorHold events

" indentation
set tabstop=2      " set tab width to 2 columns (spaces)
set shiftwidth=2   " use 2 columns (spaces) for indentation
set softtabstop=2  " fine-tuning for inserting/deletion of whitespace (equal it to shiftwidth)
set shiftround     " round indent to multiple of 'shiftwidth'; applies to > and < commands
set expandtab      " replace TAB with spaces
set breakindent    " wrap indent to match line start
set smartindent    " smarter autoindentation
set preserveindent " preserve indent structure as much as possible

" search
set hlsearch   " search highlighting on
set incsearch  " enable incremental search
set ignorecase " make searches case insensitive
set infercase  " play nicely with ignorecase
set smartcase  " make searches case sensitive if search starts with a capital

" misc. & fine-tuning
set hidden                  " vim won't complain opening a new file, even if current buffer has unsaved changes
set autoread                " autoread file modifications
set lazyredraw              " it is meant to be set temporarily only, but could potentially increase performance
set history=1000            " store more items in the command/search history
set sessionoptions+=globals " useful for saving extra info in sessions (e.g. buffer positions)

" less garbage on a disk
set nobackup
set nowritebackup
set noswapfile

source ~/.config/vim.d/vimrc.keymap      " leader settings and key bindings
source ~/.config/vim.d/vimrc.howtoquit   " disturbing quit commands aliases
source ~/.config/vim.d/vimrc.ftdetect    " a few basic filetype detection rules + markdown highlights
source ~/.config/vim.d/vimrc.snippets    " various (and manually crafted) snippets
"source ~/.config/vim.d/vimrc.noarrowkeys " hardcore mode (without arrow keys available – to learn hjkl)

" any overrides specific to the machine
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
