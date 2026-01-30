""""""""""""""""""""""""""
""" Vim options
""""""""""""""""""""""""""


" encoding
set encoding=utf-8
scriptencoding utf-8

let &t_ut=''

" File and script encoding settings for vim
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1

" filetype support
filetype plugin indent on
syntax on

"{ Builtin optional plugins
" Activate matchit plugin
runtime! macros/matchit.vim

" Activate man page plugin
runtime! ftplugin/man.vim
"}

" Cursor shape: prefer guicursor; fallback to t_SI/t_EI/t_SR (DECSCUSR)
if !has('nvim')
    " DECSCUSR: 2=block, 5=bar, 4=underline (stable variants)
    if exists('$TMUX')
        let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>[2 q\<Esc>\\"
        let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>[6 q\<Esc>\\"
        let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>[4 q\<Esc>\\"
    else
        let &t_EI = "\<Esc>[2 q"  " Normal: block
        let &t_SI = "\<Esc>[6 q"  " Insert: bar
        let &t_SR = "\<Esc>[4 q"  " Replace: underline
    endif

    " cursor mode shape
    set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkon0
endif
" fix macos switch delay
set ttimeout
set ttimeoutlen=1
set ttyfast
" toggle cursorline
"set nocursorline
":autocmd InsertEnter * set cursorline
":autocmd InsertLeave * set nocursorline

" various settings
set autoindent
set ignorecase smartcase
set backspace=indent,eol,start
set complete+=d
set completeopt=menu,menuone,noselect
set hidden
set noswapfile
set path& | let &path .= "**"
set tags=./tags;,tags;
set wildcharm=<C-z>
set wildmenu
" List all items and start selecting matches in cmd completion
set wildmode=list:full
set splitbelow splitright
set laststatus=2
"set autochdir

" visual
set number relativenumber
set ruler
set virtualedit=block
" display dots for spaces
set lcs+=space:·

" bell
set noerrorbells
set novisualbell
set t_vb=

" search
set incsearch
set hlsearch
exec "nohlsearch"

" fold settings
set foldlevelstart=999
set foldmethod=syntax

" General tab settings
set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set shiftwidth=4    " number of spaces to use for autoindent
set expandtab       " expand tab to spaces so that tabs are spaces
set shiftround

" Spell
set nospell
set spelllang=en_us,cjk

" History
set history=200
call mkdir(expand('~/.vim/tmp/backup'), 'p')
set backupdir=~/.vim/tmp/backup,.
set directory=~/.vim/tmp/backup,.
if has('persistent_undo')
    call mkdir(expand('~/.vim/tmp/undo'), 'p')
    set undofile
    set undodir=~/.vim/tmp/undo,.
endif

" Time in milliseconds to wait for a mapped sequence to complete,
" see https://unix.stackexchange.com/q/36882/221410 for more info
set timeoutlen=500

" For CursorHold events
set updatetime=800

" Clipboard settings, always use clipboard for all delete, yank, change, put
" operation, see https://stackoverflow.com/q/30691466/6064933
if get(g:, "use_system_clipboard", 0) && exists("unnamedplus")
        set clipboard^=unnamed,unnamedplus
endif

" Break line at predefined characters
set linebreak
" Character to show before the lines that have been soft-wrapped
set showbreak=↪

" show tabs and trailling spaces
set list listchars=tab:→\ ,trail:·
"set list listchars=tab:→\ ,trail:·,space:·

" Show current line where the cursor is
set cursorline

" Set a ruler at column 80, see https://stackoverflow.com/q/2447109/6064933
set colorcolumn=80

" Minimum lines to keep above and below cursor when scrolling
set scrolloff=5

" Use mouse to select and resize windows, etc.
if has('mouse')
    set mouse=a             " Enable mouse in all mode
    set mousemodel=popup    " Set the behaviour of mouse
endif

" colorscheme settings
if exists('&termguicolors')
    " If we want to use true colors, we must a color scheme which support true
    " colors, for example, https://github.com/sickill/vim-monokai
    set notermguicolors
endif

