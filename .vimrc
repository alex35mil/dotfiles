" ======= Plugins

set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'                       " Vim's Bundler

Plugin 'scrooloose/nerdtree'                        " File manager
Plugin 'wincent/command-t'                          " File finder
Plugin 'bling/vim-airline'                          " Status bars
Plugin 'ryanoasis/vim-devicons'                     " Icons
Plugin 'sjl/vitality.vim'                           " iTerm & tmux focus events integration
Plugin 'Valloric/YouCompleteMe'                     " Autocomplition for Vim
Plugin 'scrooloose/nerdcommenter'                   " Commenter
Plugin 'jiangmiao/auto-pairs'                       " Insert/delete brackets, parens, quotes in pair
Plugin 'SirVer/ultisnips'                           " Vim snippets
Plugin 'scrooloose/syntastic'                       " Linter
Plugin 'mtscout6/syntastic-local-eslint.vim'        " Prefer local eslint
Plugin 'Xuyuanp/nerdtree-git-plugin'                " Git files status in NERDTree
Plugin 'airblade/vim-gitgutter'                     " Git line status in the gutter area
Plugin 'tpope/vim-fugitive'                         " Git wrapper
Plugin 'tpope/vim-surround'                         " Fancy text wrappings
Plugin 'pangloss/vim-javascript'                    " JS Syntax
Plugin 'mxw/vim-jsx'                                " JSX Syntax

call vundle#end()


" ======= Settings

filetype plugin indent on                           " Enable file type detection

set background=dark                                 " Dark background
set t_Co=256                                        " 256 colors, please
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
set title                                           " Show the filename in the window titlebar
set showcmd                                         " Show the (partial) command as it’s being typed
set ruler                                           " Show the cursor position
set cursorline                                      " Highlight current line
set laststatus=2                                    " Always show status line
set colorcolumn=80                                  " 80 chars limit
set mouse=a                                         " Enable mouse in all modes
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
hi NonText ctermfg=bg


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

  " Handle filetypes
  autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
  autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
  autocmd BufNewFile,BufRead *.es6 setfiletype es6 syntax=javascript
  autocmd BufNewFile,BufRead *.es6 UltiSnipsAddFiletypes es6.javascript
endif


" ======= Plugins setup

" NERDTree setup
let NERDTreeShowHidden=1

" Devicons setup
let g:WebDevIconsNerdTreeAfterGlyphPadding = ' '
let g:WebDevIconsNerdTreeGitPluginForceVAlign = 1
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFoldersOpenClose = 0  " Broken: https://github.com/ryanoasis/vim-devicons/issues/130
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {}
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['jsx'] = ''

" Airline setup
let g:airline_detect_whitespace=0
let g:airline_powerline_fonts = 1
let g:airline_symbols = {}

let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1

let g:airline#extensions#syntastic#enabled = 1

" netrw setup
let g:netrw_localrmdir='rm -r'

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

" Command-T setup
let g:CommandTAlwaysShowDotFiles = 1
let g:CommandTFileScanner = 'git'
let g:CommandTTraverseSCM = 'pwd'
if &term =~ 'xterm' || &term =~ 'screen'
  let g:CommandTAcceptSelectionSplitMap = ['<C-s>', '{']
  let g:CommandTAcceptSelectionVSplitMap = ['<C-v>', '}']
  let g:CommandTCancelMap = ['<Esc>', '<F2>', '<F3>']
endif

" YouCompleteMe setup
let g:ycm_key_list_select_completion=['<Down>']
let g:ycm_key_list_previous_completion=['<Up>']

" UltiSnips setup
let g:UltiSnipsSnippetDirectories=['snips']

let g:UltiSnipsExpandTrigger='§'
let g:UltiSnipsJumpForwardTrigger='§'
let g:UltiSnipsJumpBackwardTrigger='±'

" NERDCommenter setup
let NERDSpaceDelims=1
let NERDCreateDefaultMappings=0

" Syntastic setup
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 1
let g:syntastic_javascript_checkers = ['eslint']

" vim-javascript setup
let b:javascript_fold = 0


" ======= Mappings

" First of all, remap your CapsLock key to Ctrl in System Preferences

" Set Leader char to comma
let mapleader=","

" Quit
nnoremap <Leader>q :q<CR>
nnoremap <Leader>qa :qa<CR>

" Write
nnoremap <Leader>w :w<CR>

" Show/hide NERDTree
nnoremap <F1> :NERDTreeToggle<CR>

" Show current file
nnoremap \ :NERDTreeFind<CR>

" Show Buffers
nnoremap <F2> :CommandTBuffer<CR>

" Show file finder
nnoremap <F3> :CommandT<CR>

" Close current buffer without loosing current split
nnoremap <S-w> :bp\|bd #<CR>

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
inoremap <C-b> <Esc>lxi

" Dup things
nnoremap <C-c> yyp
vnoremap <C-c> ygv<Esc>p
inoremap <C-c> <Esc>yypA

" Tab/Untab
nnoremap <Tab> V>
nnoremap <S-Tab> V<
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

" Insert mode start/end line navigation
inoremap <C-Right> <Esc>A
inoremap <C-Left> <Esc>I

" Copy all
nnoremap <C-a> :%y+<CR>

" Blank line w/o going in insert mode
nnoremap = o<Esc>
nnoremap + O<Esc>

" Clear highlighting on Space in normal mode
nnoremap <Space> :noh<CR><Esc>

" Show .vimrc
nnoremap <Leader>vii :vsp $MYVIMRC<CR>

" Without this Command-T do wierd stuff
nnoremap <Esc>^[ <Esc>^[
