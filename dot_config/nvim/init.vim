" __  ____   __  _   ___     _____ __  __ ____   ____
"|  \/  \ \ / / | \ | \ \   / /_ _|  \/  |  _ \ / ___|
"| |\/| |\ V /  |  \| |\ \ / / | || |\/| | |_) | |
"| |  | | | |   | |\  | \ V /  | || |  | |  _ <| |___
"|_|  |_| |_|   |_| \_|  \_/  |___|_|  |_|_| \_\\____|



" ===
" === Auto load for first time uses
" ===
" Install vim-plug if not found
if has('nvim')
    let s:vim_plug_path = '~/.config/nvim/autoload/plug.vim'
else
    let s:vim_plug_path = '~/.vim/autoload/plug.vim'
endif

if empty(glob(s:vim_plug_path))
    let $VIMPLUG_PATH = g:vim_config_path
    silent !curl -fLo $VIMPLUG_PATH --create-dirs
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
let maplocalleader=","
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
set signcolumn=yes
set updatetime=300
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
"" --- MacOS ---
if has('mac')
    " specify the python parser path
    let g:python3_host_prog = '/opt/homebrew/Cellar/python@3.11/3.11.2_1/bin/python3'

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


" Run chezmoi apply whenever a dotfile is saved
autocmd BufWritePost ~/.local/share/chezmoi/* ! chezmoi apply --source-path "%"


" -------which-key-prefix------
" which_key_prefix dictionary
" Second level dictionaries:
" 'name' is a special field. It will define the name of the group, e.g., leader-f is the "+file" group.
" Unnamed groups will show a default empty string.

" =======================================================
" Create menus based on existing mappings
" =======================================================
" You can pass a descriptive text to an existing mapping.
let g:which_key_map =  {}
let g:which_key_map.b = {"name": "+build"}
let g:which_key_map.f = {"name" : "+find"}
let g:which_key_map.t = {"name": "+toggle/trans"}
let g:which_key_map.o = {"name" : "+open"}
let g:which_key_map.s = {"name": "+set"}
let g:which_key_map.p = {"name": "+plugins"}
let g:which_key_map.r = {"name": "+refactor"}
let g:which_key_map.d = {"name": "+diagnostics"}

let g:which_key_map_visual = {}
let g:which_key_map_visual.r = {"name": "+refactor"}
let g:which_key_map_visual.a = {"name": "+apply-code-actions"}
let g:which_key_map_visual.f = {"name" : "+find"}

let g:which_key_map_local = {}


" ===
" === Basic Mappings
" ===
noremap <LEADER><CR> <Cmd>nohlsearch<CR><Cmd>call minimap#vim#ClearColorSearch()<CR>
let g:which_key_map['<CR>'] = 'nohlsearch'

noremap S <Cmd>w<CR>
noremap <D-c> "+y
vnoremap <D-c> "+y
noremap <D-v> "+p
inoremap <D-v> <c-r>+
cnoremap <D-v> <c-r>+
noremap Q <Cmd>q<CR>
" noremap R <Cmd>source $MYVIMRC<CR>
noremap ; :

" Copy to system clipboard
vnoremap Y "+y

" make Y to copy till the end of the line
"nnoremap Y y$

" Open up lazygit
nnoremap <c-g> <Cmd>tabe<CR>:-tabmove<CR>:term lazygit<CR>

noremap sk <Cmd>set nosplitbelow<CR>:split<CR>
noremap sj <Cmd>set splitbelow<CR>:split<CR>
noremap sh <Cmd>set nosplitright<CR>:vsplit<CR>
noremap sl <Cmd>set splitright<CR>:vsplit<CR>

noremap \k <C-w>k
noremap \j <C-w>j
noremap \h <C-w>h
noremap \l <C-w>l
"" EXAMPLES:
""  <C-w>hjkl (or<arrows>) move around windows
""  <C-w>w toggle focus window (emacs like)
""  <C-w>o fullscreen focus window
""  <C-w>c close current window
noremap J 5j
noremap K 5k
noremap W 5w
noremap B 5b

vnoremap H ^
vnoremap L $

"Emacs like navigation keys
inoremap <C-a> <C-o>^
inoremap <C-e> <C-o>$

" <C-y> move window up, <C-e> move window down
" <C-u> move half window up, <C-d> move half window down
" zz move cursor line to center, zt to top, zb to bottom

noremap <C-Up> <Cmd>res -5<CR>
noremap <C-Down> <Cmd>res +5<CR>
noremap <C-Right> <Cmd>vertical resize+5<CR>
noremap <C-Left> <Cmd>vertical resize-5<CR>

" Tab Controll
noremap ti <Cmd>tabe<CR>
noremap tl <Cmd>tabn<CR>
noremap th <Cmd>tabp<CR>
noremap tw <Cmd>tabc<CR>
noremap tmh <Cmd>tabm -<CR>
noremap tml <Cmd>tabm +<CR>
noremap Tl <Cmd>bn<CR>
noremap Th <Cmd>bp<CR>
noremap Tw <Cmd>bd<CR>

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

" === TMUX compatibility
if &term =~ '^tmux'
    echo "started with tmux mode"
elseif &term =~ '^screen'
    echo "started with screen mode"
endif


" ===
" === Other useful stuff
" ===
" Open a new instance of st with the cwd
nnoremap \t <Cmd>tabe<CR>:-tabmove<CR>:term sh -c 'st'<CR><C-\><C-N>:q<CR>

" Opening a terminal window
noremap <LEADER>` <Cmd>set splitbelow<CR>:split<CR>:res +10<CR>:term<CR>

let g:which_key_map['`'] = "open-term-below"

" Jump to the next '<++>' and edit it
noremap g= <Esc>/<++><CR>:nohlsearch<CR>c4l

" Spelling Check with <space>sc
noremap <LEADER>sc <Cmd>set spell!<CR>
let g:which_key_map.s.c = "spell-check"

" Auto change directory to current dir
"autocmd BufEnter * silent! lcd %:p:h

" Call figlet
noremap <LEADER>pf :r !figlet
let g:which_key_map.p.f = "figlet-{msgs}"

" find and replace
noremap <LEADER>rr <Cmd>%s//g<left><left>
let g:which_key_map.r.r = "find&replace"

" set wrap
noremap <LEADER>sw <Cmd>set wrap<CR>
let g:which_key_map.s.w = "wrap"
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

" typewriter mode
noremap <LEADER>st <Cmd>call ToggleTypeWriterMode()<CR>
func! ToggleTypeWriterMode()
    exec "w"
    if &scrolloff <= 5
        :set scrolloff=999
    elseif &so > 5
        :set scrolloff=5
    endif
endfunc
let g:which_key_map.s.t = "type-writer-mode"

" Correcting spelling mistakes on the fly
setlocal spell
setlocal spellfile=~/.config/nvim/spell/en.utf-8.add
set spelllang=en_us,cjk
inoremap <C-h> <c-g>u<Esc>[s1z=`]a<c-g>u
" use <C-x><C-s> to correct spell in insert mode

" open files
nnoremap <silent> <leader>oq  <Cmd>copen<CR>
nnoremap <silent> <leader>ol  <Cmd>lopen<CR>
nnoremap <silent> <leader>ov <Cmd>e $MYVIMRC<CR>
let g:which_key_map.o.q = 'quickfix'
let g:which_key_map.o.l = 'locationlist'
let g:which_key_map.o.v = 'vimrc'


" press f7 to show hlgroup
" map <F7> <Cmd>echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
" \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
" \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" ctrl + q to back to normal mode in terminal
tnoremap <c-q> <c-\><c-n>


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" User Defined Functions & Commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:global_rootmarks = [
    \ '.svn', '.git', '.hg',
    \ '.root', '.project',
    \ 'build.xml', '.cargo',
    \ '.vscode', '.vim', '.idea'
    \ ]


command! -nargs=0 OpenVimrc :e ~/.config/nvim/init.vim
command! -nargs=0 OpenZshrc :e ~/.zshrc
command! -nargs=0 OpenFishrc :e ~/.config/fish/config.fish



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Quickly Run
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
noremap cr <Cmd>call CompileRunGcc()<CR>
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
        exec "CocCommand markdown-preview-enhanced.openPreview"
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
noremap cd <Cmd>call CompileDebugGcc()<CR>


"**
"* Generate *compile_commands.json*
"*   find the closest CMakeLists.txt in parent directory and generate
"*   compile_commands.json in build folder
function! s:generate_compile_commands()
    let s:root_path = finddir('.vim/..', expand('%:p:h').';') " find the closest .vim path
    if empty(findfile('CMakeLists.txt', s:root_path, -1)) " check it contains CMakeLists.txt
        echo "Can't find CMakeLists.txt in project root " .. s:root_path .. " (marked by .vim)"
        let s:root_path = fnamemodify(findfile('CMakeLists.txt', '.;'), ':p:h') " search for CMakeLists.txt instead
    endif
    " if find CMakeLists.txt, create build/ directly
    echo 'CMakeLists.txt root_path is ' . s:root_path
    execute '!cd ' .. s:root_path .. '; cmake -DCMAKE_BUILD_TYPE=debug
        \ -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -S . -B build'
endfunction
command! -nargs=0 Gcmake :call s:generate_compile_commands()



" ====================
"     MakeMyProject
" ====================
"noremap <F6> <Cmd>call RunCmakeUpperDIR()<CR>
"func! RunCmakeUpperDIR()
    "exec "!cmake -S . -B ../build/"
"endfunc

"noremap <F7> <Cmd>call RunMakeUpperDIR()<CR>
"func! RunMakeUpperDIR()
    "exec "!make -C ../build/"
"endfunc

"noremap <F5> <Cmd>call RunAUpperDir()<CR>
"func! RunAUpperDir()
    "exec "!../a"
"endfunc




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" template
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd BufNewFile *.cpp 0r ~/.config/nvim/template/template.cpp
autocmd BufNewFile CMakeLists.txt 0r ~/.config/nvim/template/CMakeLists.txt

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""" Neovide Configurations
if exists("g:neovide")

set guifont=FiraCode\ Nerd\ Font\ Mono:h18
set linespace=0
let g:neovide_scale_factor = 1.0

"" Background Color (Currently macOS only)
if has('mac')
" g:neovide_transparency should be 0 if you want to unify transparency of content and title bar.
let g:neovide_transparency = 0.0
let g:transparency = 0.8
let g:neovide_background_color = '#0f1117'.printf('%x', float2nr(255 * g:transparency))
else
let g:neovide_transparency = 0.8
endif

" Floating Blur Amount
let g:neovide_floating_blur_amount_x = 2.0
let g:neovide_floating_blur_amount_y = 2.0

let g:neovide_hide_mouse_when_typing = v:true
let g:neovide_underline_automatic_scaling = v:true
let g:neovide_confirm_quit = v:true
let g:neovide_fullscreen = v:false
let g:neovide_input_macos_alt_is_meta = v:true

" Animations
let g:neovide_cursor_animation_length = 0.13
let g:neovide_scroll_animation_length = 0.3
let g:neovide_cursor_vfx_mode = "sonicboom"


endif




" ==========================================
" ================ Plugins =================
"
if has("nvim")
    call plug#begin('~/.config/nvim/plugged')
else
    call plug#begin('~/.vim/plugged')
endif


    " Apperance
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    " Plug 'edkolev/tmuxline.vim'
    " Plug 'tomasr/molokai'
    Plug 'sainnhe/sonokai'
    Plug 'Yggdroot/indentLine'
    "Plug 'connorholyday/vim-snazzy'
    "Plug 'bling/vim-bufferline'
    "Plug 'bpietravalle/vim-bolt'
    Plug 'wfxr/minimap.vim', {'do': ':!cargo install --locked code-minimap'}

    " General Highlighter
    Plug 'rrethy/vim-illuminate'

    " vim-surround
    Plug 'tpope/vim-surround'

    " Searching
    Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }

    " Auto complementation
    Plug 'jiangmiao/auto-pairs' "completion of delimiter

    " Auto Complete
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    "Plug 'wellle/tmux-complete.vim'
    Plug 'honza/vim-snippets' " snippets libraries

    " Autoformat
    Plug 'vim-autoformat/vim-autoformat'

    " Debug
    Plug 'puremourning/vimspector', {'do': './install_gadget.py --enable-c --enable-python'}

    " CMake
    Plug 'cdelledonne/vim-cmake'
    " Plug 'ilyachur/cmake4vim'

    " Async run tasks
    Plug 'skywind3000/asynctasks.vim'
    Plug 'skywind3000/asyncrun.vim'

    " Undo Tree
    Plug 'mbbill/undotree/'

    " Git
    Plug 'tpope/vim-fugitive'

    " Markdown
    " Plug 'suan/vim-instant-markdown', {'for': 'markdown'}
    Plug 'dhruvasagar/vim-table-mode', { 'on': 'TableModeToggle' }
    Plug 'mzlogin/vim-markdown-toc', { 'for': ['gitignore', 'markdown', 'vim-plug'] }
    Plug 'dkarter/bullets.vim'

    " LaTex
    Plug 'lervag/vimtex'

    " Bookmarks
    Plug 'kshenoy/vim-signature'

    " index dependences
    Plug 'Shougo/echodoc.vim'


    " Other useful utilities
    "Plug 'junegunn/goyo.vim' " distraction free writing mode
    "Plug 'gcmt/wildfire.vim' " in Visual mode, type i' to select all text in '', or type i) i] i} ip
    Plug 'scrooloose/nerdcommenter' " in <space>cc to comment a line
    Plug 'voldikss/vim-translator' " Neovim English to Chinese translator, support Youdao, Ciba, Bing and Google
    Plug 'easymotion/vim-easymotion' " Easy Motion! to navigate
    Plug 'liuchengxu/vim-which-key' " which-key in space-vim


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



" === airline ===
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline_powerline_fonts = 1
" let g:airline_theme='molokai'
let g:airline_theme = 'sonokai'

" === colorscheme ===
if has('termguicolors')
    set termguicolors
endif
" let g:molokai_original = 1
" let g:rehash256 = 1
let g:sonokai_style = 'andromeda'
let g:sonokai_better_performance = 1
colorscheme sonokai
hi link IlluminatedWordText Visual
hi link IlluminatedWordRead Visual
hi link IlluminatedWordWrite Visual

" === Yggdroot/indentLine ===
let g:indent_guides_guide_size      = 1  " 指定对齐线的尺寸
let g:indent_guides_start_level     = 2  " 从第二层开始可视化显示缩进
let g:indentLine_fileTypeExclude = ['coc-explorer', 'which_key']

" === minimap.vim ===
" requires code-minimap at https://github.com/wfxr/code-minimap
let g:minimap_width = 10
let g:minimap_auto_start = 0 " there are bugs when switching tabs
let g:minimap_auto_start_win_enter = 0
let g:minimap_highlight_search = 1
let g:minimap_git_colors = 1
let g:minimap_block_filetypes = [ 'fugitive', 'nerdtree', 'tagbar', 'leaderf', 'coc-explorer', 'which_key' ]
let g:minimap_close_filetypes = [ 'help' ]
nnoremap <Leader>' <cmd>MinimapToggle<CR>
let g:which_key_map["'"] = "toggle-minimap"

" === jiangmiao/auto-pairs ===
""default-settings
"let g:AutoPairsShortcutBackInsert = '<M-b>'
"let g:AutoPairsShortcutToggle = '<M-p>'
"let g:AutoPairsShortcutFastWrap = '<M-e>'
"let g:AutoPairsShortcutJump = '<M-n>'
let g:AutoPairsMapCh = 0
"Fast wrap the word. All pairs will be consider as a block (include <>).
"(|)'hello' after fast wrap at |, the word will be ('hello')
"(|)<hello> after fast wrap at |, the word will be (<hello>)
let g:AutoPairs= {'(':')', '[':']', '{':'}',"'":"'",'"':'"'}






" ===
" === coc.nvim
" ===

set hidden
set updatetime=300
set shortmess+=c
let g:coc_global_extensions = [
    \ 'coc-lists',
    \ 'coc-actions',
    \ 'coc-marketplace',
    \ 'coc-project',
    \ 'coc-dictionary',
    \ 'coc-tag',
    \ 'coc-word',
    \ 'coc-emoji',
    \ 'coc-snippets',
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
    \ 'coc-webview',
    \ 'coc-highlight',
    \ 'coc-prettier',
    \ 'coc-pyright',
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
    \ 'coc-yank',
    \ 'coc-ci',
    \ 'coc-leetcode',
    \ 'coc-tabnine'
    \]


    "\ 'coc-vetur', "vetur for vue2, use volar-tools for vue3

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Basic Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Use <tab> and <S-tab> to navigate completion list: >

    function! CheckBackSpace() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~ '\s'
    endfunction

" Insert <tab> when previous text is space, refresh completion if not.
inoremap <silent><expr> <TAB>
    \ coc#pum#visible() ?
    \   coc#pum#next(1) :
    \   coc#expandableOrJumpable() ?
    \     "\<C-r >=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
    \     CheckBackSpace() ? "\<Tab>" : coc#refresh()

" Add `:Format` command to format current buffer
command! -nargs=0 Format <Cmd>call CocActionAsync('format')
" Add `:Fold` command to fold current buffer
command! -nargs=? Fold <Cmd>call     CocAction('fold', <f-args>)
" Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   <Cmd>call     CocActionAsync('runCommand', 'editor.action.organizeImport')

inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" To make <CR> to confirm selection of selected complete item or notify coc.nvim
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" <LEADER>h to show documentation
nnoremap <silent> <LEADER>h <Cmd>call Show_documentation()<CR>
" Show hover when provider exists, fallback to vim's builtin behavior.
function! Show_documentation()
    call CocActionAsync('highlight')
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    else
        call CocAction('doHover')
    endif
endfunction

let g:which_key_map["h"] = "show-documentation"

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s)
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" <ctrl>+(shift)+p vscode like shortcuts to open command prompt
nnoremap <C-l> <Cmd>CocList<CR>
nnoremap <C-s-p> <Cmd>CocCommand<CR>
nnoremap <M-x> <Cmd>CocCommand<CR>

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gD <Cmd>tab sp<CR><Plug>(coc-definition)
nmap <silent> gt <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Search workspace symbols
nnoremap <silent><nowait> <space>os  <Cmd>CocList -I symbols<cr>
let g:which_key_map.o.s = "workspace-symbols"


" Applying code actions to the selected code block
" Example: `<leader>aap` for current paragraph
xmap <silent> <leader>a <Plug>(coc-codeaction-selected)
nmap <silent> <leader>a <Plug>(coc-codeaction-selected)
let g:which_key_map.a = "codeaction+{range}"

" Remap keys for applying code actions at the cursor position
nmap <silent> <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer
nmap <silent> <leader>ab  <Plug>(coc-codeaction-source)
let g:which_key_map.ac = "codeaction-under-cursor"
let g:which_key_map.ab = "codeaction-whole-buffer"

" Run the Code Lens action on the current line
nmap <silent> <leader>l  <Plug>(coc-codelens-action)
let g:which_key_map.l = "codelens-action"

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server
" ======================
" Select inside function.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
" Select around function.
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
" " Select inside class/struct/interface.
" xmap ic <Plug>(coc-classobj-i)
" omap ic <Plug>(coc-classobj-i)
" " Select around class/struct/interface.
" xmap ac <Plug>(coc-classobj-a)
" omap ac <Plug>(coc-classobj-a)

" EXAMPLES: vim has implemented many ranges as follows
" [w]'word', [W]'WORD', [s]'sentence', [p]'paragraph', [t]'tags', [b]'()'
"
" Use CTRL-S for selections ranges
" NOTE: Requires 'textDocument/selectionRange' support of language server
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)


" Remap <C-f> and <C-b> to scroll float windows/popups
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Jump into first float window
nmap <silent> <C-w><C-p> <Plug>(coc-float-jump)

" Add (Neo)Vim's native statusline support
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Coc-extensions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" Manage extensions
nnoremap <silent><nowait> <space>pm  <Cmd>CocList extensions<cr>
let g:which_key_map.p.m = "manage-extensions"

" === coc-highlight
autocmd CursorHold * silent call CocActionAsync('highlight')


" === coc-snippets
" Use <C-l> for trigger snippet expand.
" imap <C-l> <Plug>(coc-snippets-expand)
" Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)
" Use <C-k> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<c-k>'
" Use <C-j> for jump to next placeholder, it's default of coc.nvim
let g:coc_snippet_next = '<c-j>'
" Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)

" Use <leader>x for convert visual selected code to snippet
xmap <leader>x  <Plug>(coc-convert-snippet)
let g:which_key_map_visual.x = "convert-snippet"


" === coc-diagnostic
nnoremap <silent> <LEADER>dt <Cmd>call CocAction('diagnosticToggle')<cr>
nnoremap <silent> <LEADER>dd <Cmd>CocList diagnostics<cr>
nnoremap <silent> <LEADER>da <Cmd>CocList diagnostics<cr>
" Apply the most preferred quickfix action to fix diagnostic on the current line
nnoremap <leader>df  <Plug>(coc-fix-current)
nmap <silent> g[ <Plug>(coc-diagnostic-prev)
nmap <silent> g] <Plug>(coc-diagnostic-next)

let g:which_key_map.d.d = "show-diagnostics"
let g:which_key_map.d.t = "toggle-diagnostics"
let g:which_key_map.d.f = "quick-fix"

" === coc-rename
nmap <leader>rn <Plug>(coc-rename)
" create a refactor window
nmap <leader>rf <Plug>(coc-refactor)
let g:which_key_map.r.n = "rename"
let g:which_key_map.r.f = "open-refactor-window"
" Change all word in the buffer
nmap <leader>rw <Cmd>CocCommand document.renameCurrentWord<CR>
let g:which_key_map.r.w = "all-current-word"
" Remap keys for applying refactor code actions
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>rs <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>rs <Plug>(coc-codeaction-refactor-selected)
let g:which_key_map.r.e = "refactor"
let g:which_key_map.r.s = "refactor-selected"
let g:which_key_map_visual.r.s = "refactor-selected"


" === coc-clangd
nnoremap <leader>th <Cmd>CocCommand clangd.switchSourceHeader<CR>
let g:which_key_map.t.h = "toggle-header-src"


" === coc-yank
nnoremap <silent> <space>y <Cmd>CocList -A --normal yank<cr>
let g:which_key_map.y = "yank-list"

" === coc-explorer
nmap <leader>e <Cmd>CocCommand explorer<CR>
let g:which_key_map.e = "explorer"

" === coc-project
nnoremap <silent> <leader>op <Cmd>CocList project<CR>
let g:which_key_map.o.p = "projects"

" === coc-multiple-cursors
nmap <silent> <C-c> <Plug>(coc-cursors-position)
nmap <silent> <C-x> <Plug>(coc-cursors-word)
xmap <silent> <C-x> <Plug>(coc-cursors-range)

" === coc-ci
nmap <silent> w <Plug>(coc-ci-w)
nmap <silent> b <Plug>(coc-ci-b)

" === coc-prettier
vmap <leader>rp  <Plug>(coc-format-selected)
nmap <leader>rp  <Plug>(coc-format-selected)

let g:which_key_map.r.p = "format-selected"
let g:which_key_map_visual.r.p ="format-selected"

" custom command :Prettier to force format current document
command! -nargs=0 Prettier <Cmd>CocCommand prettier.forceFormatDocument

xmap <leader>rP  <Cmd>Prettier<CR>
let g:which_key_map.r.P = "force-format-file"

nmap <leader>rc <Cmd>CocCommand prettier.createConfigFile<CR>

let g:which_key_map.r.c = "create-prettier-config"

" === coc-translator
"nmap ts <Plug>(coc-translator-p)
" 重新映射 for do codeAction of selected region
" function! s:cocActionsOpenFromSelected(type) abort
  " execute 'CocCommand actions.open ' . a:type
" endfunction
" xmap <silent> <leader>a <Cmd>execute 'CocCommand actions.open ' . visualmode()<CR>
" nmap <silent> <leader>a <Cmd>set operatorfunc=<SID>cocActionsOpenFromSelected<CR>g@

" === coctodolist
nnoremap <leader>tn <Cmd>CocCommand todolist.create<CR>
nnoremap <leader>tl <Cmd>CocList todolist<CR>
nnoremap <leader>tu <Cmd>CocCommand todolist.download<CR>:CocCommand todolist.upload<CR>
let g:which_key_map.t.n = "Todo-create"
let g:which_key_map.t.l = "Todo-list"
let g:which_key_map.t.u = "Todo-update"

" === coc-tasks
noremap <silent> <leader>tt <Cmd>CocList tasks<CR>
let g:which_key_map.t.t = "Tasks-list"

" === coc-markdown-preview-enhanced
nnoremap <leader>om <Cmd>CocCommand markdown-preview-enhanced.openPreview<CR>
let g:which_key_map.o.m = "mardown-preview"

" === coc-webview
let g:which_key_map.p.w = {"name": "+webview"}
nnoremap <leader>pwl <Cmd>CocList webview<CR>
let g:which_key_map.p.w.l = "list"


" === coc-leetcode
let g:which_key_map.p.l = {
    \ "name": "+leetcode",
    \ "l": [":CocCommand leetcode.login"        , "login"],
    \ "p": [":CocList LeetcodeProblems"         , "list-problems"],
    \ "r": [":CocCommand leetcode.run"          , "run"],
    \ "s": [":CocCommand leetcode.submit"       , "submit"],
    \ "c": [":CocCommand leetcode.comments"     , "comments"]
    \ }


" === vim-cmake
let g:cmake_build_dir_location = 'build'
let g:cmake_root_markers = g:global_rootmarks
let g:cmake_generate_options = ['-DCMAKE_EXPORT_COMPILE_COMMANDS=ON']


" ===
" === vimspector
" ===
" debugger for vim
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
let g:which_key_map_vimspector = {
    \ "<F5>":           "vimsp-continue",
    \ "<S-F5>":         "vimsp-stop",
    \ "<C-S-F5>":       "vimsp-restart",
    \ "<F6>":           "vimsp-pause",
    \ "<F9>":           "vimsp-toggle-breakpoint",
    \ "<S-F9>":         "vimsp-addfunc-breakpoint",
    \ "<F10>":          "vimsp-step-over",
    \ "<F11>":          "vimsp-vimsp-step-into",
    \ "<S-F11>":        "vimsp-vimsp-step-out"
    \ }

let g:which_key_map.p.v = {"name": "+vimspector"}
nnoremap <Leader>pvc <Cmd>WhichKey 'vimspector-cheat-sheet'<CR>
call which_key#register('vimspector-cheat-sheet', "g:which_key_map_vimspector")
let g:which_key_map.p.v.c = "show-cheat-sheet"

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

command! -nargs=0 Gvimspector <Cmd>call s:generate_vimspector_conf()
nnoremap <Leader>pvg <Cmd>Gvimspector<CR>
let g:which_key_map.p.v.g = "generate-vimsp-conf"


nmap <Leader>pve <Plug>VimspectorBalloonEval
xmap <Leader>pve <Plug>vimspectorBalloonEval
let g:which_key_map.p.v.e = "balloon-eval"



" ===
" === LeaderF
" ===
let g:Lf_HideHelp = 0
let g:Lf_UseCache = 0
let g:LF_ShowHidden = 1
let g:Lf_IgnoreCurrentBufferName = 1
" let g:Lf_GtagsAutoUpdate = 1
" popup mode
let g:Lf_WindowPosition = 'popup'
let g:Lf_PreviewInPopup = 1
let g:Lf_PopupPreviewPosition = 'bottom'
let g:Lf_StlSeparator = { 'left': "\ue0b0", 'right': "\ue0b2", 'font': "DejaVu Sans Mono for Powerline" }
let g:Lf_PreviewResult = {'File': 1, 'Buffer': 1, 'Mru': 1, 'BufTag': 1, 'Function': 1, 'Gtags': 1, 'Rg': 1}
" set the working directory
let g:Lf_WorkingDirectoryMode = 'Ac'
let g:Lf_RootMarkers = (g:global_rootmarks)
let g:Lf_DefaultExternalTool = 'rg'
" ignore
let g:Lf_WildIgnore = {
    \ 'dir': ['.svn', '.git', '.hg', '.vscode', '.vim', '.idea', 'CMakeFiles', 'node_modules'],
    \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]', '.DS_Store']
    \}
let g:Lf_CommandMap = {'<C-J>': ['<C-J>','<Down>'], '<C-K>': ['<Up>','<C-K>'], '<Down>': ['<C-Down>'], '<Up>': ['<C-Up>'], '<C-Down>': ['<M-Down>','<C-S-Down>'], '<C-Up>': ['<M-Up>','<C-S-Up>']}
" <C-J/K>,<Down/Up>: select down/up
" <C-Up/Down>: history search
" <M-Down/Up>,<C-S-Down/Up>,<C-S-J/K>: scroll preview window


let g:Lf_ShortcutF = "<leader>ff"
let g:Lf_ShortcutB = "<leader>fb"
nnoremap <silent> <leader>fg <Cmd>LeaderfFunction<CR>
nnoremap <silent> <leader>ft <Cmd>LeaderfBufTag<CR>
nnoremap <silent> <leader>fl <Cmd>LeaderfLine<CR>
nnoremap <silent> <leader>fm <Cmd>LeaderfMru<CR>
nnoremap <silent> <leader>fc <Cmd>LeaderfHistoryCmd<CR>
nnoremap <silent> <leader>fx <Cmd>LeaderfCommand<CR>
nnoremap <silent> <leader>fw <Cmd>LeaderfWindow<CR>
nnoremap <silent> <leader>fh <Cmd>LeaderfHelp<CR>

" take advantage of rg
let g:Lf_RgConfig = [
        \ "--max-columns=150",
        \ "--type-add 'web:*.{html,css,js}*'",
        \ "--glob=!git/*",
        \ "--hidden"
    \ ]
" search word under cursor, the pattern is treated as regex, and enter normal mode directly
nnoremap <silent> <leader>fs :<C-U><C-R>=printf("Leaderf! rg --current-buffer -e %s ", expand("<cword>"))<CR><CR>
nnoremap <silent> <leader>fS :<C-U><C-R>=printf("Leaderf! rg -e %s ", expand("<cword>"))<CR><CR>
" search visually selected text literally
xnoremap <leader>fs :<C-U><C-R>=printf("Leaderf! rg -F -e %s ", leaderf#Rg#visual())<CR><CR>
nnoremap <leader>fo :<C-U>Leaderf! rg --recall<CR>

" nnoremap <silent> <leader>fi :<C-U><C-R>=printf("Leaderf rg --current-buffer -e %s ", "")<CR><CR>

" should use `Leaderf gtags --update` first
"let g:Lf_GtagsAutoGenerate = 0
"let g:Lf_Gtagslabel = 'native-pygments'
"noremap <leader>fr :<C-U><C-R>=printf("Leaderf! gtags -r %s --auto-jump", expand("<cword>"))<CR><CR>
"noremap <leader>fd :<C-U><C-R>=printf("Leaderf! gtags -d %s --auto-jump", expand("<cword>"))<CR><CR>
"noremap <leader>fo :<C-U><C-R>=printf("Leaderf! gtags --recall %s", "")<CR><CR>
"noremap <leader>fn :<C-U><C-R>=printf("Leaderf gtags --next %s", "")<CR><CR>
"noremap <leader>fp :<C-U><C-R>=printf("Leaderf gtags --previous %s", "")<CR><CR>

let g:which_key_map.f.g = "function"
let g:which_key_map.f.t = "bufTag"
let g:which_key_map.f.m = "mru-files"
let g:which_key_map.f.l = "lines"
let g:which_key_map.f.b = "buffer"
let g:which_key_map.f.c = "history-commands"
let g:which_key_map.f.x = "commands"
let g:which_key_map.f.h = "helps"
let g:which_key_map.f.s = "current-word-buf"
let g:which_key_map.f.S = "current-word-glob"
let g:which_key_map.f.w = "windows"
let g:which_key_map.f.o = "recent-search"

let g:which_key_map_visual.f.s = "current-word"



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
map <LEADER>tm <Cmd>TableModeToggle<CR>


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
" silent! unmap <LEADER>ig
" autocmd WinEnter * silent! unmap <LEADER>ig


" ===
" === nerdcommenter
" ===
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

let g:which_key_map.c = {
    \ "name": "+comment",
    \ "c": "comment",
    \ "n": "nesting",
    \ "s": "pretty-block-formatted",
    \ "m": "multipart-delimiters",
    \ "i": "individually",
    \ " ": "toggle-state(top-line)",
    \ "y": "yanked-first",
    \ "$": "comment-to-EOL",
    \ "A": "append-to-EOF",
    \ "u": "uncomment"
    \ }


" ===
" === Easy Motion
" ===

map <Leader> <Plug>(easymotion-prefix)

" <Leader>f{char} to move to {char}
map  <Leader>m <Plug>(easymotion-bd-f)
nmap <Leader>m <Plug>(easymotion-overwin-f)
let g:which_key_map.m = "move-to-{char}"
let g:which_key_map_visual.m = "move-to-{char}"

" s{char}{char} to move to {char}{char}
nmap s <Plug>(easymotion-overwin-f2)

" Move to line
map  <Leader>L <Plug>(easymotion-bd-jk)
nmap <Leader>L <Plug>(easymotion-overwin-line)
let g:which_key_map.L = "move-to-line"
let g:which_key_map_visual.L = "move-to-line"

" Move to word
map  <Leader>w <Plug>(easymotion-bd-w)
nmap <Leader>w <Plug>(easymotion-overwin-w)
let g:which_key_map.w = "move-to-word"
let g:which_key_map_visual.w = "move-to-word"



" ===
" === Goyo
" ===
"map <LEADER>gy <Cmd>Goyo<CR>


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
let g:undotree_SetFocusWhenToggle = 1
nnoremap L <Cmd>UndotreeToggle<CR>


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
" if has('nvim')
" nnoremap <silent><expr> <C-w><C-f> translator#window#float#has_scroll() ?
                            " \ translator#window#float#scroll(1) : "\<M-f>"
" nnoremap <silent><expr> <C-w><C-b> translator#window#float#has_scroll() ?
                            " \ translator#window#float#scroll(0) : "\<M-f>"
" endif



" ==== skywind3000 (compile && run) asyncrun ====
" ==== https://github.com/skywind3000/asyncrun.vim/blob/master/README-cn.md ====
"
" 自动打开 quickfix window ，高度为 6
let g:asyncrun_open = 6

" 任务结束时候响铃提醒
let g:asyncrun_bell = 1

" 设置 F10 打开/关闭 Quickfix 窗口
" nnoremap <F10> <Cmd>call asyncrun#quickfix_toggle(6)<cr>

"nnoremap <silent> <F9> <Cmd>AsyncRun clang++ -Wall -O2 "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>
" nnoremap <silent> <F8> <Cmd>AsyncRun -cwd=<root>/src/ cmake -B "../build/" <cr>
" nnoremap <silent> <F9> <Cmd>AsyncRun -cwd=<root>/build/ make <cr>

" 按F10以term运行编译好的程序，显示在新建tab中
" nnoremap <silent> <F5> <Cmd>AsyncRun -raw -cwd=<root> -mode=term -pos=tab -rows=10 ./a <cr>

" 设置识别项目目录
let g:asyncrun_rootmarks = copy(g:global_rootmarks)



"index dependences (echodoc)
set noshowmode
let g:echodoc_enable_at_startup = 1




" ===
" === vim-which-key
" ===
set timeoutlen=500

let g:which_key_use_floating_win = 1
let g:which_key_floating_relative_win = 1
let g:which_key_floating_opts = { 'col': '-3', 'row': '-1' }
let g:which_key_fallback_to_native_key=1
let g:which_key_run_map_on_popup = 1
let g:which_key_display_names = {'<CR>': '↵', '<TAB>': '⇆'}
autocmd FileType which_key highlight WhichKeyFloating ctermfg=252 ctermbg=252


nnoremap <silent> <leader> <Cmd>WhichKey '<Space>'<CR>
vnoremap <silent> <leader> <Cmd>WhichKeyVisual '<Space>'<CR>

nnoremap <silent> <localleader> <Cmd>WhichKey ','<CR>









" =======================================================
" Create menus not based on existing mappings:
" =======================================================
" Provide commands(ex-command, <Plug>/<C-W>/<C-d> mapping, etc.)
" and descriptions for the existing mappings.
"
" Note:
" Some complicated ex-cmd may not work as expected since they'll be
" feed into `feedkeys()`, in which case you have to define a decicated
" Command or function wrapper to make it work with vim-which-key.
" Ref issue #126, #133 etc.


call which_key#register('<Space>', "g:which_key_map", 'n')
call which_key#register('<Space>', "g:which_key_map_visual", 'v')
call which_key#register(',', "g:which_key_map_local")


