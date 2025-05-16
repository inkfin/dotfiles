""""""""""""""""""""""""""
""" Vim options
""""""""""""""""""""""""""

" Preferences
if !exists('g:minimal_vimrc') || !g:minimal_vimrc
    let transparent = 0
    let enable_lsp = 0
    let force_use_ale = 1
endif


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

" change cursor shape
if !has('nvim')
    " Change cursor shapes based on whether we are in insert mode,
    " see https://vi.stackexchange.com/questions/9131/i-cant-switch-to-cursor-in-insert-mode
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
    if exists('&t_SR')
        let &t_SR = "\<Esc>]50;CursorShape=2\x7"
    endif

    if exists('$TMUX')
        "let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
        "let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
        let &t_SI = "\<esc>[5 q"
        let &t_EI = "\<esc>[2 q"
        if exists('&t_SR')
            let &t_SR = "\<esc>[3 q"
        endif
    endif

    " The number of color to use
    set t_Co=256
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
set visualbell
set virtualedit=block
" display dots for spaces
set lcs+=space:·

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
set updatetime=300

" Clipboard settings, always use clipboard for all delete, yank, change, put
" operation, see https://stackoverflow.com/q/30691466/6064933
set clipboard+=unnamed
set clipboard+=unnamedplus

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

if exists('g:transparent') && g:transparent
    augroup TransparentColorscheme
    autocmd!
        autocmd ColorScheme * highlight Normal ctermbg=None guibg=NONE
    augroup END
endif
