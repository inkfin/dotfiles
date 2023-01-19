" __  ____   __  _   ___     _____ __  __ ____   ____
"|  \/  \ \ / / | \ | \ \   / /_ _|  \/  |  _ \ / ___|
"| |\/| |\ V /  |  \| |\ \ / / | || |\/| | |_) | |
"| |  | | | |   | |\  | \ V /  | || |  | |  _ <| |___
"|_|  |_| |_|   |_| \_|  \_/  |___|_|  |_|_| \_\\____|



" ===
" === Auto load for first time uses
" ===
" Install vim-plug if not found
if empty(glob('~/.config/nvim/autoload/plug.vim'))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif



" ====================
" === Editor Setup ===
" ====================
" ===
" === System
" ===
"set clipboard+=unnamedplus
let &t_ut=''
set autochdir


" ===
" === Editor behavior
" ===
set nocompatible
hi Normal ctermfg=252 ctermbg=none
let mapleader=" "
syntax on
set hlsearch
exec "nohlsearch"
set incsearch
set ignorecase
set smartcase
set shortmess+=c
set inccommand=split
"set clipboard=unnamed
set completeopt=longest,noinsert,menuone,noselect,preview
set ttyfast "should make scrolling faster
set lazyredraw "same as above
autocmd VimLeave * call system("echo -n $'" . escape(getreg(), "'") . "' | xsel -ib")


set visualbell
silent !mkdir -p ~/.config/nvim/tmp/backup
silent !mkdir -p ~/.config/nvim/tmp/undo
"silent !mkdir -p ~/.config/nvim/tmp/sessions
set backupdir=~/.config/nvim/tmp/backup,.
set directory=~/.config/nvim/tmp/backup,.
if has('persistent_undo')
    set undofile
    set undodir=~/.config/nvim/tmp/undo,.
endif
set colorcolumn=100
set updatetime=100
set virtualedit=block

au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif


"--fold setting--
set foldmethod=syntax "用语法高亮定义折叠
set foldlevel=100 "启动vim不要自动折叠
set foldcolumn=0 "设置折叠栏宽度

set number
set relativenumber
set cursorline
set wrap
set showcmd
set wildmenu

" --tab settings--
set ts=4
set expandtab
%retab!
set shiftwidth=4
set softtabstop=4


" ===
" === Terminal Behaviors
" ===
let g:neoterm_autoscroll = 1
autocmd TermOpen term://* startinsert
"tnoremap <C-N> <C-\><C-N>
"tnoremap <C-O> <C-\><C-N><C-O>
let g:terminal_color_0  = '#000000'
let g:terminal_color_1  = '#FF5555'
let g:terminal_color_2  = '#50FA7B'
let g:terminal_color_3  = '#F1FA8C'
let g:terminal_color_4  = '#BD93F9'
let g:terminal_color_5  = '#FF79C6'
let g:terminal_color_6  = '#8BE9FD'
let g:terminal_color_7  = '#BFBFBF'
let g:terminal_color_8  = '#4D4D4D'
let g:terminal_color_9  = '#FF6E67'
let g:terminal_color_10 = '#5AF78E'
let g:terminal_color_11 = '#F4F99D'
let g:terminal_color_12 = '#CAA9FA'
let g:terminal_color_13 = '#FF92D0'
let g:terminal_color_14 = '#9AEDFE'


" === Platform Specific Settings ===
if has('mac')
    " specify the python parser path
    let g:python3_host_prog = '/opt/homebrew/bin/python3.11'
endif

" Run chezmoi apply whenever a dotfile is saved
autocmd BufWritePost ~/.local/share/chezmoi/* ! chezmoi apply --source-path "%"


 
" ===
" === Basic Mappings
" ===
noremap <LEADER><CR> :nohlsearch<CR>

noremap S :w<CR>
noremap <C-S> :w<CR>
noremap Q :q<CR>
noremap R :source $MYVIMRC<CR>
noremap ; :

" Copy to system clipboard
vnoremap Y "+y

" make Y to copy till the end of the line
"nnoremap Y y$

" Folding
noremap <silent><LEADER>\ za

" Open up lazygit
noremap \g :Git 
noremap <c-g> :tabe<CR>:-tabmove<CR>:term lazygit<CR>
" nnoremap <c-n> :tabe<CR>:-tabmove<CR>:term lazynpm<CR>

noremap sk :set nosplitbelow<CR>:split<CR>
noremap sj :set splitbelow<CR>:split<CR>
noremap sh :set nosplitright<CR>:vsplit<CR>
noremap sl :set splitright<CR>:vsplit<CR>

noremap \k <C-w>k
noremap \j <C-w>j
noremap \h <C-w>h
noremap \l <C-w>l
noremap J 5j
noremap K 5k
noremap W 5w
noremap B 5b

"Emacs like navigation keys
inoremap <C-f> <C-O>h
inoremap <C-b> <C-O>l
inoremap <M-f> <C-O>w
inoremap <M-b> <C-O>b
inoremap <C-P> <C-O>k
inoremap <C-n> <C-O>j

inoremap <C-a> <C-O>^
inoremap <C-e> <C-O>$


" Ctrl + J or K will move down/up the view port without moving the cursor
" noremap <C-> 5<C-y>
" noremap <C-> 5<C-e>

nnoremap <C-K> :res -5<CR>
nnoremap <C-J> :res +5<CR>
nnoremap <C-L> :vertical resize+5<CR>
nnoremap <C-H> :vertical resize-5<CR>

" Tab Controll
noremap ti :tabe<CR>
noremap tl :tabn<CR>
noremap th :tabp<CR>
noremap tw :tabc<CR>
noremap tmh :tabm -<CR>
noremap tml :tabm +<CR>

" Place the two screens up and down
"noremap sc <C-w>t<C-w>S
" Place the two screens side by side
"noremap sv <C-w>t<C-w>H

" Rotate screens
noremap srh <C-w>b<C-w>K
noremap src <C-w>b<C-w>K
noremap srv <C-w>b<C-w>H

filetype on
filetype indent on
filetype plugin on
filetype plugin indent on
set mouse=a
set encoding=utf-8
let &t_ut=''
set list
set listchars=tab:▸\ ,trail:▫
set scrolloff=5
set viewoptions=cursor,folds,slash,unix
set tw=0
set indentexpr=
set backspace=indent,eol,start
set whichwrap=b,s,h,l,<,>,[,]
set foldmethod=indent
set foldlevel=99
set foldenable
set formatoptions-=tc
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"
set laststatus=2
set autochdir
"set showmatch"vims bracket pair function
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif


" ===
" === Other useful stuff
" ===
" Open a new instance of st with the cwd
nnoremap \t :tabe<CR>:-tabmove<CR>:term sh -c 'st'<CR><C-\><C-N>:q<CR>

" Opening a terminal window
noremap <LEADER>/ :set splitbelow<CR>:split<CR>:res +10<CR>:term<CR>

" Press space twice to jump to the next '<++>' and edit it
noremap <LEADER><LEADER> <Esc>/<++><CR>:nohlsearch<CR>c4l

" Spelling Check with <space>sc
noremap <LEADER>sc :set spell!<CR>

noremap <c-c> zz

" Auto change directory to current dir
"autocmd BufEnter * silent! lcd %:p:h

" Call figlet
noremap tx :r !figlet

" find and replace
noremap \s :%s//g<left><left>

" set wrap
noremap <LEADER>sw :set wrap<CR>
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

" typewriter mode
noremap Tw :call ToggleTypeWriterMode()<CR>
func! ToggleTypeWriterMode()
    exec "w"
    if &scrolloff <= 5
        :set scrolloff=999
    elseif &so > 5
        :set scrolloff=5
    endif
endfunc


" press f7 to show hlgroup
"map <F7> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
"\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
"\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" ctrl + q to back to normal mode in terminal
tnoremap <c-q> <c-\><c-n>


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" User Defined Functions & Commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! -nargs=0 OpenVimrc :e ~/.config/nvim/init.vim
command! -nargs=0 OpenZshrc :e ~/.zshrc
command! -nargs=0 OpenFishrc :e ~/.config/fish/config.fish



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Quickly Run
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
noremap cr :call CompileRunGcc()<CR>
func! CompileRunGcc()
    exec "w"
    if &filetype == 'c'
        exec "!clang % -o %<"
        exec "!time ./%<"
    elseif &filetype == 'rust'
        set splitbelow
        exec "!rustc %"
        :sp
        :res +5
        :term time ./%<
    elseif &filetype == 'cpp'
        set splitbelow
        exec "!clang++ -std=c++17 % -Wall -o %<"
        :sp
        :res +10
        :term time ./%<
    elseif &filetype == 'java'
        exec "!javac %"
        exec "!time java %<"
    elseif &filetype == 'sh'
        :!time bash %
    elseif &filetype == 'python'
        set splitbelow
        :sp
        :term python3 %
    elseif &filetype == 'html'
        silent! exec "!".g:mkdp_browser." % &"
    elseif &filetype == 'markdown'
        exec "InstantMarkdownPreview"
    elseif &filetype == 'tex'
        silent! exec "VimtexStop"
        silent! exec "VimtexCompile"
    elseif &filetype == 'dart'
        exec "CocCommand flutter.run -d ".g:flutter_default_device
        silent! exec "CocCommand flutter.dev.openDevLog"
    elseif &filetype == 'javascript'
        set splitbelow
        :sp
        :term export DEBUG="INFO,ERROR,WARNING"; node --trace-warnings .
    elseif &filetype == 'go'
        set splitbelow
        :sp
        :term go run .
    endif
endfunc

" generate debug files
func! CompileDebugGcc()
    exec "w"
    if &filetype == 'c'
        exec "!clang % -g -O0 -o %<"
        exec "!time ./%<"
    elseif &filetype == 'cpp'
        set splitbelow
        exec "!clang++ -std=c++17 % -g -O0 -o %<"
        :sp
        :res +10
        :term ./%<
    endif
endfunc
noremap cd :call CompileDebugGcc()<CR>

" generate compile commands
function! s:generate_compile_commands()
    if empty(glob('CMakeLists.txt'))
        echo "Can't find CMakeLists.txt"
        return
    endif
    if empty(glob('.vscode'))
        execute 'silent !mkdir .vscode'
    endif
    execute '!cmake -DCMAKE_BUILD_TYPE=debug
        \ -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -S . -B .vscode'
endfunction
command! -nargs=0 Gcmake :call s:generate_compile_commands()

" ====================
"     MakeMyProject
" ====================
"noremap <F6> :call RunCmakeUpperDIR()<CR>
"func! RunCmakeUpperDIR()
    "exec "!cmake -S . -B ../build/"
"endfunc

"noremap <F7> :call RunMakeUpperDIR()<CR>
"func! RunMakeUpperDIR()
    "exec "!make -C ../build/"
"endfunc

"noremap <F5> :call RunAUpperDir()<CR>
"func! RunAUpperDir()
    "exec "!../a"
"endfunc




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" template
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd BufNewFile *.cpp 0r ~/.config/nvim/template/template.cpp
autocmd BufNewFile CMakeLists.txt 0r ~/.config/nvim/template/CMakeLists.txt

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""




" ==========================================
" ================ Plugins =================
"
call plug#begin('~/.config/nvim/plugged')
"call plug#begin('~/.vim/plugged')


    " Apperance
    Plug 'vim-airline/vim-airline'
    "Plug 'cateduo/vsdark.nvim'
    Plug 'tomasr/molokai'
    Plug 'Yggdroot/indentLine'
    "Plug 'connorholyday/vim-snazzy'
    "Plug 'bling/vim-bufferline'
    "Plug 'bpietravalle/vim-bolt'

    " Status line
    Plug 'ojroques/vim-scrollstatus'

    " General Highlighter
    Plug 'rrethy/vim-illuminate'

    " File navigation
    Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
    Plug 'Xuyuanp/nerdtree-git-plugin'

    " Searching
    Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }

    " Auto complementation
    Plug 'jiangmiao/auto-pairs' "completion of delimiter

    " Auto Complete
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    "Plug 'wellle/tmux-complete.vim'

    " Autoformat
    Plug 'vim-autoformat/vim-autoformat'

    " Debug
    Plug 'puremourning/vimspector', {'do': './install_gadget.py --enable-c --enable-python'}

    " Undo Tree
    Plug 'mbbill/undotree/'


    " Git
    "Plug 'rhysd/conflict-marker.vim'
    "Plug 'tpope/vim-fugitive'
    "Plug 'mhinz/vim-signify'
    "Plug 'gisphm/vim-gitignore', { 'for': ['gitignore', 'vim-plug'] }


    " Markdown
    Plug 'suan/vim-instant-markdown', {'for': 'markdown'}
    Plug 'dhruvasagar/vim-table-mode', { 'on': 'TableModeToggle' }
    Plug 'mzlogin/vim-markdown-toc', { 'for': ['gitignore', 'markdown', 'vim-plug'] }
    Plug 'dkarter/bullets.vim'


    " Bookmarks
    Plug 'kshenoy/vim-signature'

    " index dependences
    Plug 'Shougo/echodoc.vim'


    " Other useful utilities
    Plug 'terryma/vim-multiple-cursors'
    "Plug 'junegunn/goyo.vim' " distraction free writing mode
    "Plug 'gcmt/wildfire.vim' " in Visual mode, type i' to select all text in '', or type i) i] i} ip
    Plug 'scrooloose/nerdcommenter' " in <space>cc to comment a line
    Plug 'voldikss/vim-translator' " Neovim English to Chinese translator, support Youdao, Ciba, Bing and Google
    Plug 'easymotion/vim-easymotion' " Easy Motion! to navigate


    " Dependencies
    Plug 'MarcWeber/vim-addon-mw-utils'
    Plug 'kana/vim-textobj-user'
    Plug 'fadein/vim-FIGlet'


    " WakaTime for Vim
    Plug 'wakatime/vim-wakatime'


    "Platform Specific
    "    I know this is workaround, TODO: fix this
    "-- MacOS --
    if has('mac')
        Plug 'ybian/smartim' "Change the input method in normal mode
    endif


call plug#end()

" ====================== Plugins End ========================
" ===========================================================





" === cateduo/vsdark.nvim ===
set termguicolors
"let g:vsdark_style = "dark"
"colorscheme vsdark
colorscheme molokai
let g:molokai_original = 1
let g:rehash256 = 1

" === Yggdroot/indentLine ===
let g:indent_guides_guide_size      = 1  " 指定对齐线的尺寸
let g:indent_guides_start_level     = 2  " 从第二层开始可视化显示缩进


" === jiangmiao/auto-pairs ===
let g:AutoPairsFlyMode = 0
let g:AutoPairsShortcutBackInsert = '' "default <M-b> conflict
let g:AutoPairsShortcutFastWrap = '<M-e>'
"Fast wrap the word. all pairs will be consider as a block (include <>).
"(|)'hello' after fast wrap at |, the word will be ('hello')
"(|)<hello> after fast wrap at |, the word will be (<hello>)


" === vim-autoformat ===




" ===
" === NERDTree
" ===
map tt :NERDTreeToggle<CR>
let NERDTreeMapOpenExpl = ""
let NERDTreeMapUpdir = ""
let NERDTreeMapUpdirKeepOpen = "l"
let NERDTreeMapOpenSplit = ""
let NERDTreeOpenVSplit = ""
let NERDTreeMapActivateNode = "i"
let NERDTreeMapOpenInTab = "o"
let NERDTreeMapPreview = ""
let NERDTreeMapCloseDir = "n"
let NERDTreeMapChangeRoot = "y"


" ==
" == NERDTree-git
" ==
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ "Unknown"   : "?"
    \ }
let g:NERDTreeGitStatusUseNerdFonts = 1 " you should install nerdfonts by yourself. default: 0
let g:NERDTreeGitStatusShowIgnored = 1 " a heavy feature may cost much more time. default: 0



" ===
" === coc.nvim
" ===
set hidden
set updatetime=300
set shortmess+=c
let g:coc_global_extensions = [
    \ 'coc-actions',
    \ 'coc-clangd',
    \ 'coc-cmake',
    \ 'coc-rust-analyzer',
    \ 'coc-css',
    \ 'coc-diagnostic',
    \ 'coc-explorer',
    \ 'coc-flutter-tools',
    \ 'coc-gitignore',
    \ 'coc-html',
    \ 'coc-json',
    \ 'coc-lists',
    \ 'coc-prettier',
    \ 'coc-pyright',
    \ 'coc-snippets',
    \ 'coc-sourcekit',
    \ 'coc-stylelint',
    \ 'coc-syntax',
    \ 'coc-tasks',
    \ 'coc-todolist',
    \ 'coc-eslint' ,
    \ 'coc-translator',
    \ 'coc-tslint-plugin',
    \ 'coc-tsserver',
    \ '@yaegassy/coc-volar',
    \ '@yaegassy/coc-volar-tools',
    \ 'coc-vimlsp',
    \ 'coc-yaml',
    \ 'coc-yank']


    "\ 'coc-vetur', "vetur for vue2, use volar-tools for vue3

""""""""""""""""""""
" Vital Settings!!!
""""""""""""""""""""

" Use <tab> and <S-tab> to navigate completion list: >

    function! CheckBackSpace() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~ '\s'
    endfunction

" Insert <tab> when previous text is space, refresh completion if not.
let g:coc_snippet_next = '<tab>'
inoremap <silent><expr> <TAB>
    \ coc#pum#visible() ?
    \   coc#pum#next(1) :
    \   coc#expandableOrJumpable() ?
    \     "\<C-r >=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
    \     CheckBackSpace() ? "\<Tab>" : coc#refresh()


inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" To make <CR> to confirm selection of selected complete item or notify coc.nvim
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"



" <LEADER>h to show documentation
inoremap <silent><expr> <c-space> coc#refresh()
inoremap <silent><expr> <c-o> coc#refresh()
nnoremap <LEADER>h :call Show_documentation()<CR>
" Show hover when provider exists, fallback to vim's builtin behavior.
function! Show_documentation()
    call CocActionAsync('highlight')
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    else
        call CocAction('doHover')
    endif
endfunction


" diagnostic info
nnoremap <silent><nowait> <LEADER>d :CocList diagnostics<cr>
nmap <silent> <LEADER>- <Plug>(coc-diagnostic-prev)
nmap <silent> <LEADER>= <Plug>(coc-diagnostic-next)
nnoremap <c-c> :CocCommand<CR>

" Text Objects
xmap kf <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap kf <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)
xmap kc <Plug>(coc-classobj-i)
omap kc <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Useful commands
" yank
nnoremap <silent> <space>y :<C-u>CocList -A --normal yank<cr>
" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gD :tab sp<CR><Plug>(coc-definition)
nmap <silent> gt <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Rename
nmap <leader>rn <Plug>(coc-rename)
" Coc explorer
nmap <leader>e :CocCommand explorer<CR>

" coc-translator
"nmap ts <Plug>(coc-translator-p)
" 重新映射 for do codeAction of selected region
function! s:cocActionsOpenFromSelected(type) abort
  execute 'CocCommand actions.open ' . a:type
endfunction
xmap <silent> <leader>a :<C-u>execute 'CocCommand actions.open ' . visualmode()<CR>
nmap <silent> <leader>a :<C-u>set operatorfunc=<SID>cocActionsOpenFromSelected<CR>g@
" coctodolist
"nnoremap <leader>tn :CocCommand todolist.create<CR>
"nnoremap <leader>tl :CocList todolist<CR>
"nnoremap <leader>tu :CocCommand todolist.download<CR>:CocCommand todolist.upload<CR>
" coc-tasks
"noremap <silent> <leader>ts :CocList tasks<CR>
" coc-snippets
imap <C-l> <Plug>(coc-snippets-expand)
vmap <C-e> <Plug>(coc-snippets-select)
"let g:coc_snippet_next = '<c-e>'
"let g:coc_snippet_prev = '<c-n>'
"imap <C-e> <Plug>(coc-snippets-expand-jump)
let g:snips_author = 'Inkfin'
autocmd BufRead,BufNewFile tsconfig.json set filetype=jsonc



" ===
" === vimspector
" ===
let g:vimspector_enable_mappings = 'VISUAL_STUDIO'
"=========================================================================================================================
"|      _Key_      |                _Mapping_                |                         _Function_                        |
"=========================================================================================================================
"| 'F5'            | '<Plug>VimspectorContinue'              | When debugging, continue. Otherwise start debugging.      |
"-------------------------------------------------------------------------------------------------------------------------
"| 'Shift F5'      | '<Plug>VimspectorStop'                  | Stop debugging.                                           |
"-------------------------------------------------------------------------------------------------------------------------
"| 'Ctrl Shift F5' | '<Plug>VimspectorRestart'               | Restart debugging with the same configuration.            |
"-------------------------------------------------------------------------------------------------------------------------
"| 'F6'            | '<Plug>VimspectorPause'                 | Pause debuggee.                                           |
"-------------------------------------------------------------------------------------------------------------------------
"| 'F9'            | '<Plug>VimspectorToggleBreakpoint'      | Toggle line breakpoint on the current line.               |
"-------------------------------------------------------------------------------------------------------------------------
"| 'Shift F9'      | '<Plug>VimspectorAddFunctionBreakpoint' | Add a function breakpoint for the expression under cursor |
"-------------------------------------------------------------------------------------------------------------------------
"| 'F10'           | '<Plug>VimspectorStepOver'              | Step Over                                                 |
"-------------------------------------------------------------------------------------------------------------------------
"| 'F11'           | '<Plug>VimspectorStepInto'              | Step Into                                                 |
"-------------------------------------------------------------------------------------------------------------------------
"| 'Shift F11'     | '<Plug>VimspectorStepOut'               | Step out of current function scope                        |
"-------------------------------------------------------------------------------------------------------------------------

function! s:generate_vimspector_conf()
  if empty(glob( '.vimspector.json' ))
    if &filetype == 'cpp'
      !cp ~/.config/nvim/vimspector_conf/cpp.json ./.vimspector.json
    elseif &filetype == 'c'
      !cp ~/.config/nvim/vimspector_conf/c.json ./.vimspector.json
    elseif &filetype == 'python'
      !cp ~/.config/nvim/vimspector_conf/python.json ./.vimspector.json
    endif
  endif
  e .vimspector.json
endfunction

command! -nargs=0 Gvimspector :call s:generate_vimspector_conf()

nmap <Leader>v <Plug>VimspectorBalloonEval
xmap <Leader>v <Plug>vimspectorBalloonEval



" ===
" === LeaderF
" ===
let g:Lf_HideHelp = 0
let g:Lf_UseCache = 0
let g:Lf_IgnoreCurrentBufferName = 1
" popup mode
let g:Lf_WindowPosition = 'popup'
let g:Lf_PreviewInPopup = 1
let g:Lf_StlSeparator = { 'left': "\ue0b0", 'right': "\ue0b2", 'font': "DejaVu Sans Mono for Powerline" }
let g:Lf_PreviewResult = {'Function': 0, 'BufTag': 0 }
" set the working directory
let g:Lf_WorkingDirectoryMode = 'Ac'
let g:Lf_RootMarkers = ['.git', '.svn', '.hg', '.vscode', '.project', '.root', '.idea', '.vim']
let g:Lf_DefaultExternalTool = 'rg'
" ignore
let g:Lf_WildIgnore = {
    \ 'dir': ['.svn', '.git', '.hg', '.vscode', '.ideas', 'CMakeFiles', 'node_modules'],
    \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]']
    \}

let g:Lf_ShortcutF = "<leader>ff"
noremap <leader>fg :LeaderfFunction<CR>
noremap <leader>ft :<C-U><C-R>=printf("Leaderf bufTag %s", "")<CR><CR>
noremap <leader>fv :<C-U><C-R>=printf("Leaderf bufTag %s", "")<CR><CR>
noremap <leader>fl :<C-U><C-R>=printf("Leaderf line %s", "")<CR><CR>
noremap <leader>fb :<C-U><C-R>=printf("Leaderf buffer %s", "")<CR><CR>
noremap <leader>fm :<C-U><C-R>=printf("Leaderf mru %s", "")<CR><CR>

"noremap <C-B> :<C-U><C-R>=printf("Leaderf! rg --current-buffer -e %s ", expand("<cword>"))<CR><CR>
"noremap <C-F> :<C-U><C-R>=printf("Leaderf! rg -e %s ", expand("<cword>"))<CR><CR>
" search visually selected text literally
xnoremap <leader>fs :<C-U><C-R>=printf("Leaderf! rg -F -e %s ", leaderf#Rg#visual())<CR><CR>
noremap <leader>go :<C-U>Leaderf! rg --recall<CR>

" should use `Leaderf gtags --update` first
"let g:Lf_GtagsAutoGenerate = 0
"let g:Lf_Gtagslabel = 'native-pygments'
"noremap <leader>fr :<C-U><C-R>=printf("Leaderf! gtags -r %s --auto-jump", expand("<cword>"))<CR><CR>
"noremap <leader>fd :<C-U><C-R>=printf("Leaderf! gtags -d %s --auto-jump", expand("<cword>"))<CR><CR>
"noremap <leader>fo :<C-U><C-R>=printf("Leaderf! gtags --recall %s", "")<CR><CR>
"noremap <leader>fn :<C-U><C-R>=printf("Leaderf gtags --next %s", "")<CR><CR>
"noremap <leader>fp :<C-U><C-R>=printf("Leaderf gtags --previous %s", "")<CR><CR>



" ===
" === iamcco/markdown-preview.vim
" ===

"let g:mkdp_auto_start = 0
"let g:mkdp_auto_close = 1
"let g:mkdp_refresh_slow = 0
"let g:mkdp_command_for_global = 0
"let g:mkdp_open_to_the_world = 0
"let g:mkdp_open_ip = ''
"let g:mkdp_browser = 'chromium'
"let g:mkdp_echo_preview_url = 0
"let g:mkdp_browserfunc = ''
"let g:mkdp_preview_options = {
    "\ 'mkit': {},
    "\ 'katex': {},
    "\ 'uml': {},
    "\ 'maid': {},
    "\ 'disable_sync_scroll': 0,
    "\ 'sync_scroll_type': 'middle',
    "\ 'hide_yaml_meta': 1
    "\ }
"let g:mkdp_markdown_css = ''
"let g:mkdp_highlight_css = ''
"let g:mkdp_port = ''
"let g:mkdp_page_title = '「${name}」'



" ===
" === suan/vim-instant-markdown
" ===
"Uncomment to override defaults:
"let g:instant_markdown_slow = 1
"let g:instant_markdown_autostart = 0
"let g:instant_markdown_open_to_the_world = 1
"let g:instant_markdown_allow_unsafe_content = 1
"let g:instant_markdown_allow_external_content = 0
let g:instant_markdown_mathjax = 1
let g:instant_markdown_mermaid = 1
"let g:instant_markdown_logfile = '/tmp/instant_markdown.log'
"let g:instant_markdown_autoscroll = 0
"let g:instant_markdown_port = 8888
"let g:instant_markdown_python = 1



" tamlok/Vim-Markdown
 let g:markdown_enable_conceal = 1


" ===
" === vim-table-mode
" ===
map <LEADER>tm :TableModeToggle<CR>


" ===
" === mython-syntax
" ===
let g:python_highlight_all = 1
" let g:python_slow_sync = 0


" ===
" === vim-indent-guide
" ===
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 1
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_color_change_percent = 1
silent! unmap <LEADER>ig
autocmd WinEnter * silent! unmap <LEADER>ig


" ===
" === Easy Motion
" ===

map , <Plug>(easymotion-prefix)

" <Leader>f{char} to move to {char}
"map  ,f <Plug>(easymotion-bd-f)
nmap ,f <Plug>(easymotion-overwin-f)

" s{char}{char} to move to {char}{char}
nmap ,s <Plug>(easymotion-overwin-f2)

" Move to line
"map  ,l <Plug>(easymotion-bd-jk)
nmap ,l <Plug>(easymotion-overwin-line)

" Move to word
map  ,w <Plug>(easymotion-bd-w)
nmap ,w <Plug>(easymotion-overwin-w)



" ===
" === Goyo
" ===
"map <LEADER>gy :Goyo<CR>


" ===
" === vim-signiture
" ===
let g:SignatureMap = {
        \ 'Leader'             :  "m",
        \ 'PlaceNextMark'      :  "m,",
        \ 'ToggleMarkAtLine'   :  "m.",
        \ 'PurgeMarksAtLine'   :  "dm-",
        \ 'DeleteMark'         :  "dm",
        \ 'PurgeMarks'         :  "dm/",
        \ 'PurgeMarkers'       :  "dm?",
        \ 'GotoNextLineAlpha'  :  "m<LEADER>",
        \ 'GotoPrevLineAlpha'  :  "",
        \ 'GotoNextSpotAlpha'  :  "m<LEADER>",
        \ 'GotoPrevSpotAlpha'  :  "",
        \ 'GotoNextLineByPos'  :  "",
        \ 'GotoPrevLineByPos'  :  "",
        \ 'GotoNextSpotByPos'  :  "mn",
        \ 'GotoPrevSpotByPos'  :  "mp",
        \ 'GotoNextMarker'     :  "",
        \ 'GotoPrevMarker'     :  "",
        \ 'GotoNextMarkerAny'  :  "",
        \ 'GotoPrevMarkerAny'  :  "",
        \ 'ListLocalMarks'     :  "m/",
        \ 'ListLocalMarkers'   :  "m?",
        \ }


" ===
" === Undotree
" ===
let g:undotree_DiffAutoOpen = 0
map L :UndotreeToggle<CR>


" ===
" === vim-translator
" ===
let g:translator_target_lang = 'zh' " defult 'zh'
let g:translator_source_lang = 'auto' " defult 'auto'
let g:translator_default_engines = ['youdao', 'bing', 'haici'] " Available: 'baicizhan', 'bing', 'google', 'haici', 'iciba', 'sdcv', 'trans', 'youdao'
" Default: If g:translator_target_lang is 'zh', ['baicizhan', 'bing', 'google', 'haici', 'youdao'], otherwise ['google']
let g:translator_history_enable = 'true' "defult false
let g:translator_window_type = 'popup' "defult popup; 'preview'
let g:translator_window_max_width = 0.6 "Type int (number of columns) or float (between 0 and 1). If float, the height is relative to &lines. Default: 0.6
" <Leader>t 翻译光标下的文本，在命令行回显
nmap <silent> <Leader>ts <Plug>Translate
vmap <silent> <Leader>ts <Plug>TranslateV
" <Leader>w 翻译光标下的文本，在窗口中显示
nmap <silent> <Leader>tw <Plug>TranslateW
vmap <silent> <Leader>tw <Plug>TranslateWV
" <Leader>r 替换光标下的文本为翻译内容
"nmap <silent> <Leader>r <Plug>TranslateR
"vmap <silent> <Leader>r <Plug>TranslateRV

"Once the translation window is opened, type <C-w>p to jump into it and again to jump back
"Beside, there is a function which can be used to scroll window, only works in neovim.
nnoremap <silent><expr> <C-w><C-f> translator#window#float#has_scroll() ?
                            \ translator#window#float#scroll(1) : "\<M-f>"
nnoremap <silent><expr> <C-w><C-b> translator#window#float#has_scroll() ?
                            \ translator#window#float#scroll(0) : "\<M-f>"



"" ==== skywind3000 (compile && run) asyncrun ====
"" ==== https://github.com/skywind3000/asyncrun.vim/blob/master/README-cn.md ====
""
"" 自动打开 quickfix window ，高度为 6
"let g:asyncrun_open = 6
"
"" 任务结束时候响铃提醒
"let g:asyncrun_bell = 1
"
"" 设置 F10 打开/关闭 Quickfix 窗口
"nnoremap <F10> :call asyncrun#quickfix_toggle(6)<cr>
"
""nnoremap <silent> <F9> :AsyncRun clang++ -Wall -O2 "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>
"nnoremap <silent> <F8> :AsyncRun -cwd=<root>/src/ cmake -B "../build/" <cr>
"nnoremap <silent> <F9> :AsyncRun -cwd=<root>/build/ make <cr>
"
"" 按F10以term运行编译好的程序，显示在新建tab中
"nnoremap <silent> <F5> :AsyncRun -raw -cwd=<root> -mode=term -pos=tab -rows=10 ./a <cr>
"
"" 设置识别项目目录
"let g:asyncrun_rootmarks = ['.svn', '.git', '.root', '_darcs', 'build.xml'] 



"index dependences (echodoc)
set noshowmode
let g:echodoc_enable_at_startup = 1


""""" Platform Specific """""
"" --- MacOS ---
if has('mac')

    " === ybian/smartim ===
    "    some people reported that it is slow while editing with vim-multiple-cursors, to fix this, put this in .vimrc:
    let g:smartim_default = 'com.apple.keylayout.ABC'
    function! Multiple_cursors_before()
      let g:smartim_disable = 1
    endfunction
    function! Multiple_cursors_after()
      unlet g:smartim_disable
    endfunction

endif

