" Use the Tomorrow-Night-Bright theme
colorscheme Tomorrow-Night-Bright

" Use Vim settings, rather then Vi
set nocompatible

" Enable syntax highlighting
syntax on

" Enable line numbers
set number

" Show the current mode
set showmode

" Show the filename in the window titlebar
set title

" Show the (partial) command as it’s being typed
set showcmd

" Show the cursor position
set ruler

" Highlight current line
set cursorline

" Highlight searches
set hlsearch

" Ignore case of searches
set ignorecase

" Highlight dynamically as pattern is typed
set incsearch

" Always show status line
set laststatus=2

" Enable mouse in all modes
set mouse=a

" Turn wrap off
set nowrap

" Automatic commands
if has("autocmd")
  " Enable file type detection
  filetype plugin indent on
  " Treat .json files as .js
  autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
  " Treat .md files as Markdown
  autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
endif

" Indents: 2 spaces
set tabstop=2
set shiftwidth=2
set expandtab
