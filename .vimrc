colorscheme sorcerer                        " Use theme
syntax on                                   " Enable syntax highlighting

scriptencoding utf-8                        " UTF-8 all the way
set encoding=utf-8 nobomb                   " Use UTF-8 without BOM

set nobackup                                " Everything will be ok
set nowritebackup
set noswapfile

set nocompatible                            " Enable Vim's *cool* mode
set number                                  " Enable line numbers
set showmode                                " Show the current mode
set title                                   " Show the filename in the window titlebar
set showcmd                                 " Show the (partial) command as it’s being typed
set ruler                                   " Show the cursor position
set cursorline                              " Highlight current line
set laststatus=2                            " Always show status line
set mouse=a                                 " Enable mouse in all modes
set nowrap                                  " Turn wrap off
set clipboard+=unnamed                      " OSX clipboard sharing
set backspace=indent,eol,start              " Delete in insert mode

set novisualbell                            " Turn noise off
set noerrorbells
set vb t_vb=

set tabstop=2                               " Indents: 2 spaces
set softtabstop=2
set shiftwidth=2
set expandtab
set smarttab                                " Smart indents
set autoindent
set smartindent
set list                                    " Show invisibles
set lcs=space:·,tab:▸\ ,eol:¬               " Define invisibles

set hlsearch                                " Highlight searches
set ignorecase                              " Ignore case of searches
set incsearch                               " Highlight dynamically as pattern is typed

nnoremap <esc> :noh<return><esc>            " Clear highlighting on escape in normal mode
nnoremap <esc>^[ <esc>^[

set splitright                              " Open new split panes to right
set splitbelow                              " Open new split panes to bottom

let g:netrw_localrmdir='rm -r'              " Allow netrw to remove non-empty local directories

filetype plugin indent on                   " Enable file type detection

" Automatic commands
if has("autocmd")
  autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript  " Treat .json files as .js
  autocmd BufNewFile,BufRead *.md setlocal filetype=markdown            " Treat .md files as Markdown
endif
