set nocompatible              " be iMproved, required
filetype off                  " required

" For MacVim, add path for MacPorts.
if has("gui_macvim")
  let $PATH .= ':/opt/local/bin:/opt/local/sbin'
endif

" Set python checkers for syntastic.
let g:syntastic_python_checkers = ['pyflakes', 'python']

let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_aggregate_errors = 1

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" My Plugins here:
"
" original repos on github
Plugin 'Lokaltog/vim-easymotion'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'scrooloose/syntastic'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'Crapworks/python_fn.vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'Valloric/YouCompleteMe'
Plugin 'jiangmiao/auto-pairs'
Plugin 'tpope/vim-surround'
Plugin 'kien/ctrlp.vim'
Plugin 'jeetsukumaran/vim-buffergator'
Plugin 'bronson/vim-trailing-whitespace'
Plugin 'tpope/vim-fugitive'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'bling/vim-airline'
Plugin 'Shougo/vimproc.vim'
Plugin 'Shougo/unite.vim'
Plugin 'haya14busa/incsearch.vim'
Plugin 'jeetsukumaran/vim-indentwise'
" vim-scripts repos
Plugin 'Smart-Home-Key'
Plugin 'snipMate'
Plugin 'ack.vim'
Plugin 'matchit.zip'
Plugin 'indent-motion'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

set incsearch
set hlsearch
"nnoremap <CR> :nohlsearch<CR>
nnoremap <Space> :nohlsearch<CR>
" TAB key to open/close folds.
nnoremap <tab> za

" For YouCompleteMe config
" Use built-in YCM config file.
let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
" No blacklist for YCM, let YCM support all file types.
let g:ycm_filetype_blacklist = {}

" keybind : from http://blog.jobbole.com/58978/
nnoremap <leader>gl :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>gf :YcmCompleter GoToDefinition<CR>
nnoremap <leader>gg :YcmCompleter GoToDefinitionElseDeclaration<CR>

" For CtrlP config
let g:ctrlp_map = '<c-p>'
set wildignore+=*.pyc,*.o,*.obj,*.sys,*.dll

" For buffergator config
let g:buffergator_sort_regime = 'mru'

" For vim-gitgutter
nmap ]h <Plug>GitGutterNextHunk
nmap [h <Plug>GitGutterPrevHunk

" For vim-airline
" In text console mode + solarized theme, Airline looks bad.
" Fix it.
if !has("gui_running")
  let g:airline_theme='dark'
endif

" For unite.vim
" Set to use ack to find.
let g:unite_source_grep_command='ack'
let g:unite_source_grep_default_opts='--noheading --nocolor --nopager'
let g:unite_source_grep_recursive_opt=''

" For incsearch.vim
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

"let g:incsearch#auto_nohlsearch = 1
map n  <Plug>(incsearch-nohl-n)
map N  <Plug>(incsearch-nohl-N)
map *  <Plug>(incsearch-nohl-*)
map #  <Plug>(incsearch-nohl-#)
map g* <Plug>(incsearch-nohl-g*)
map g# <Plug>(incsearch-nohl-g#)

" For Smart-Home-Key
map <silent> <Home> :SmartHomeKey <CR>
imap <silent> <Home> <C-O>:SmartHomeKey<CR>

set cursorline
set smartindent
set shiftwidth=2
set expandtab
set showtabline=2
set laststatus=2
set nocompatible
set showcmd
set sessionoptions=blank,buffers,curdir,folds,help,resize,tabpages,winsize
set backspace=indent,eol,start
set history=200
set hidden
" set visual bell : no beep
set vb

filetype plugin on
filetype indent on

set noswapfile

syntax on

set background=dark
"set background=light
colorscheme solarized

set noimdisable
set iminsert=0
set imsearch=0

set suffixes-=.h

if has("win32")
  let Tlist_Ctags_Cmd = '\ctags\ctags.exe'
endif

au BufRead,BufNewFile SConstruct set filetype=python

set fileencodings-=latin1
set fileencodings+=cp950,sjis,latin1

" No preview window when auto-completion
set completeopt-=preview

" Enable bindings to <M-..> keys.
if has("gui_macvim")
  set macmeta
endif
