" ======= Plugins

set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'                       " Vim's Bundler

Plugin 'scrooloose/nerdtree'                        " File manager
Plugin 'godlygeek/csapprox'                         " Transparent vim
Plugin 'ctrlpvim/ctrlp.vim'                         " Finder
Plugin 'Shougo/neocomplete.vim'                     " Autocompletion
Plugin 'jszakmeister/vim-togglecursor'              " Change cursor shape in Insert mode
Plugin 'vim-scripts/BufOnly.vim'                    " Close all buffers except current
Plugin 'wesQ3/vim-windowswap'                       " Splits swapper
Plugin 'scrooloose/nerdcommenter'                   " Commenter
Plugin 'jiangmiao/auto-pairs'                       " Insert/delete brackets, parens, quotes in pair
Plugin 'Xuyuanp/nerdtree-git-plugin'                " Git files status in NERDTree
Plugin 'airblade/vim-gitgutter'                     " Git line status in the gutter area
Plugin 'tpope/vim-fugitive'                         " Git wrapper
Plugin 'tpope/vim-surround'                         " Fancy text wrappings

call vundle#end()


" ======= Settings

filetype plugin indent on                           " Enable file type detection

set background=dark                                 " Dark background
set t_Co=256                                        " 256 colors, please
set t_ut=                                           " Fix bg color inside tmux sessions
syntax on                                           " Enable syntax highlighting
colorscheme Tomorrow-Night-Eighties                 " Use theme

scriptencoding utf-8                                " UTF-8 all the way
set encoding=utf-8 nobomb                           " Use UTF-8 without BOM

set nobackup                                        " Everything will be ok
set nowritebackup
set noswapfile

set autoread                                        " Autoread files

set number                                          " Enable line numbers
set noshowmode                                      " Don't show the current mode, it's in status line
set showcmd                                         " Show the (partial) command as it’s being typed
set ruler                                           " Show the cursor position
set cursorline                                      " Highlight current line
set laststatus=2                                    " Always show status line
set colorcolumn=80                                  " 80 chars limit
set ttyfast                                         " Send more characters for redraws
set mouse=a                                         " Enable mouse in all modes
set ttymouse=xterm2                                 " Make it usable in iTerm2
set nowrap                                          " Turn wrap off
set clipboard+=unnamed                              " OSX clipboard sharing
set backspace=indent,eol,start                      " Delete in insert mode
set timeoutlen=500                                  " Be faster
set ttimeoutlen=10

set wildmenu                                        " Enable autocompletion for Vim's commands
set wildmode=longest:full,full
set wildignore=*.swp,*.bak,**/.git/*

set novisualbell                                    " Turn noise off
set noerrorbells
set vb t_vb=

set tabstop=2                                       " Indents: 2 spaces
set softtabstop=2
set shiftwidth=2
set expandtab

set smarttab                                        " Smart indents
set autoindent
set smartindent

set hlsearch                                        " Highlight searches
set ignorecase                                      " Ignore case of searches
set incsearch                                       " Highlight dynamically as pattern is typed

set splitright                                      " Open new split panes to right
set splitbelow                                      " Open new split panes to bottom

set list                                            " Show invisibles
set lcs=tab:▸\ ,eol:¬                               " Define invisibles
" set lcs=space:·,tab:▸\ ,eol:¬                     " Or with space

" Hide ~~~ noise
hi NonText      ctermfg=bg
hi StatusLine   ctermbg=239  ctermfg=bg
hi StatusLineNC ctermbg=NONE ctermfg=bg
hi VertSplit    ctermbg=NONE ctermfg=bg
hi ColorColumn  ctermbg=NONE

" ======= Functions

" Strips trailing whitespaces and blank lines at the end of the file
fun! <SID>StripTrailingWhitespacesAndBlankLinesAtTheEnd()
  %s/\($\n\s*\)\+\%$//e
  let file_type = &filetype
  if file_type != 'markdown'
    let l = line('.')
    let c = col('.')
    %s/\s\+$//e
    call cursor(l, c)
  endif
endfun

" Strips whitespaces and blank lines at the end of the file + saves all on focus lost
fun! <SID>SaveOnBlur()
  let file_path = expand('%')
  if filewritable(file_path) == 1 && file_path !~ '.*/vim/.*/doc/.*'
    call <SID>StripTrailingWhitespacesAndBlankLinesAtTheEnd()
    exec 'silent! wa'
  endif
endfun


" ======= Autocommands

if has("autocmd")
  " Open NERDTree on start if no file were specified
  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

  " Update file if it was changed outside of Vim
  autocmd BufEnter,FocusGained * silent! !

  " Strip whitespaces and blank lines at the end of the file + save all on focus lost
  autocmd BufLeave,FocusLost * call <SID>SaveOnBlur()

  " Trim whitespaces and blank lines at the end of the file on save
  autocmd BufWritePre *.* call <SID>StripTrailingWhitespacesAndBlankLinesAtTheEnd()

  " Enable omni completion
  autocmd FileType css,scss setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS

  " Handle filetypes
  autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
  autocmd BufNewFile,BufRead *.es6 setlocal filetype=javascript
  autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
endif


" ======= Plugins setup

" NERDTree setup
let NERDTreeMinimalUI = 1
let NERDTreeShowHidden = 1

" NERDTree Git setup
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "~",
    \ "Untracked" : "⍨",
    \ "Staged"    : "⍢",
    \ "Renamed"   : "⎌",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "⍤",
    \ "Dirty"     : "∙",
    \ "Clean"     : "⎀",
    \ "Unknown"   : "?"
    \ }

let g:CSApprox_hook_post = [
    \ 'highlight Normal            ctermbg=NONE',
    \ 'highlight LineNr            ctermbg=NONE',
    \ 'highlight SignifyLineAdd    cterm=bold ctermbg=NONE ctermfg=green',
    \ 'highlight SignifyLineDelete cterm=bold ctermbg=NONE ctermfg=red',
    \ 'highlight SignifyLineChange cterm=bold ctermbg=NONE ctermfg=yellow',
    \ 'highlight SignifySignAdd    cterm=bold ctermbg=NONE ctermfg=green',
    \ 'highlight SignifySignDelete cterm=bold ctermbg=NONE ctermfg=red',
    \ 'highlight SignifySignChange cterm=bold ctermbg=NONE ctermfg=yellow',
    \ 'highlight SignColumn        ctermbg=NONE',
    \ 'highlight CursorLine        ctermbg=NONE cterm=NONE',
    \ 'highlight Folded            ctermbg=NONE cterm=bold',
    \ 'highlight FoldColumn        ctermbg=NONE cterm=bold',
    \ 'highlight NonText           ctermbg=NONE',
    \ 'highlight clear LineNr'
    \]

" ctrlp setup
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
let g:ctrlp_show_hidden = 1
let g:ctrlp_prompt_mappings = {'PrtExit()': ['<Esc>', '<F2>', '<F3>']}

" neocomplete setup
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#sources#syntax#min_keyword_length = 1

" togglecursor setup
let g:togglecursor_default = 'block'

" windowswap setup
let g:windowswap_map_keys = 0

" NERDCommenter setup
let NERDSpaceDelims=1
let NERDCreateDefaultMappings=0
let g:NERDCustomDelimiters = {
  \ 'scss': { 'left': '//' },
  \ }


" ======= Mappings

" ProTip: Remap your CapsLock key to Ctrl in System Preferences.

" Set Leader char to comma
let mapleader=","

" Quit
nnoremap <Leader>q :q<CR>

" Write
nnoremap <Leader>w :w<CR>

" Show/hide NERDTree (press twice b/c of tmux prefix binding)
nnoremap <F1> :NERDTreeToggle<CR>

" Focus on current file in NERDTree
nnoremap \ :NERDTreeFind<CR>

" Show Buffers
nnoremap <F2> :CtrlPBuffer<CR>

" Show file finder
nnoremap <F3> :CtrlP<CR>

" Swap windows
nnoremap <silent> § :call WindowSwap#EasyWindowSwap()<CR>

" On/off focus mode for current split
nnoremap <Leader>ff :tabedit %<CR>
nnoremap <Leader>fd :tabclose<CR>

" Close current buffer without loosing current split
nnoremap <C-w> :bp\|bd #<CR>

" Close all buffers except current
nnoremap <Leader>xx :BufOnly<CR>

" Easier split navigations
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>
nnoremap <C-l> <C-w><C-l>
nnoremap <C-h> <C-w><C-h>

nnoremap <C-Down> <C-w><C-j>
nnoremap <C-Up> <C-w><C-k>
nnoremap <C-Right> <C-w><C-l>
nnoremap <C-Left> <C-w><C-h>

" Easier split resizes: Alt-+, Alt--, Alt-], Alt-[
nnoremap ≠ <C-w>+
nnoremap – <C-w>-
nnoremap ‘ <C-w>>
nnoremap “ <C-w><

" Comment/uncomment lines
map <Leader>cc <Plug>NERDCommenterToggle

" Better screen navigation
nnoremap <S-Down> <C-d>
nnoremap <S-Up> <C-u>

nnoremap <S-j> <C-d>
nnoremap <S-k> <C-u>

" Delete forward in insert mode
inoremap § <Esc>lxi

" Dup things
nnoremap <C-d> yyp
vnoremap <C-d> ygv<Esc>p
inoremap <C-d> <Esc>yypA

" Tab/Untab
nnoremap <Tab> V>
nnoremap <S-Tab> V<
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

" Insert mode start/end line navigation
inoremap <C-Right> <Esc>A
inoremap <C-Left> <Esc>I

" Select/copy/delete all
nnoremap <C-a> ggVG
nnoremap <C-c> :%y+<CR>
nnoremap <C-x> ggVGd

" Blank line w/o going in insert mode
nnoremap = o<Esc>
nnoremap + O<Esc>

" Expand snippets on Tab
imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
  \ "\<Plug>(neosnippet_expand_or_jump)"
  \: pumvisible() ? "\<C-n>" : "\<Tab>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
  \ "\<Plug>(neosnippet_expand_or_jump)"
  \: "\<Tab>"

" Clear highlighting on Space in normal mode
nnoremap <Space> :noh<CR><Esc>

" Show .vimrc
nnoremap <Leader>vii :vsp $MYVIMRC<CR>

" Without this Command-T do weird stuff
" nnoremap <Esc>^[ <Esc>^[
