filetype plugin on
filetype indent on

syntax on
syntax enable

set background=dark
set termguicolors
colorscheme gruvbox

set mouse=a
set clipboard=unnamedplus

set wildmenu
set wildmode=longest:full,full
set wildignore=*.swp,*.bak,**/.git/*

set novisualbell
set noerrorbells
set t_vb=
set tm=500

set nobackup
set nowritebackup
set noswapfile

set number
set showcmd
set ruler
set colorcolumn=80
set nowrap

set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

set smarttab
set autoindent
set smartindent

set list                                     " Show invisibles
set lcs=tab:▸\ ,eol:¬                        " Define invisibles
" set lcs=space:·,tab:▸\ ,eol:¬              " Or with space

set splitright
set splitbelow

set fcs=eob:\                                " Removes ~~~

" NERD Tree
let NERDTreeMinimalUI = 1
let NERDTreeShowHidden = 1

autocmd VimEnter * NERDTree

" Key bindings
let mapleader = ","

nnoremap <Leader>q :q<CR>
nnoremap <Leader>w :w<CR>
nnoremap <leader>n :NERDTreeFocus<CR>
