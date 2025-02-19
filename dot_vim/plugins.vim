""""""""""""""""""""
""" Plugins
""""""""""""""""""""

" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
    let $VIMPLUG_PATH = g:vim_config_path
    silent !curl -fLo $VIMPLUG_PATH --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


call plug#begin('~/.vim/plugged')

" plug self
Plug 'junegunn/vim-plug'


"" EDITING

" completion
if (v:version < 910)
Plug 'girishji/vimcomplete'
else
Plug 'dense-analysis/ale'
endif

" file explorer
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'

" vim-surround
Plug 'tpope/vim-surround'

" completion of delimiter
Plug 'jiangmiao/auto-pairs'

" comment line
Plug 'scrooloose/nerdcommenter'

" undo Tree
Plug 'mbbill/undotree'

" navigate
Plug 'easymotion/vim-easymotion'


"" DECORATION

" statusline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'Yggdroot/indentLine'

" highlighter
Plug 'rrethy/vim-illuminate'

" terminal
Plug 'voldikss/vim-floaterm'


call plug#end()


""" Configurations

" vim-surround
" tutorials: <https://github.com/tpope/vim-surround>

" nerdcommenter
let g:NERDCreateDefaultMappings = 0
let g:NERDCommentEmptyLines = 0
let g:NERDToggleCheckAllLines = 0
let g:NERDCustomDelimiters = {
\    'c': { 'left': '//' }
\}
nmap gcc <Plug>NERDCommenterToggle
vmap gc <Plug>NERDCommenterToggle

" nerdtree
let g:NERDTreeFileLines = 1
nnoremap <leader>e <CMD>NERDTreeToggle<CR>

" vim-airline
let g:airline_theme='angr'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline_powerline_fonts = 1

" indentLine
let g:indent_guides_guide_size      = 1  " 指定对齐线的尺寸
let g:indent_guides_start_level     = 2  " 从第二层开始可视化显示缩进
let g:indentLine_fileTypeExclude = ['coc-explorer', 'which_key']

" autopairs
let g:AutoPairsMapCh = 0
let g:AutoPairs= {'(':')', '[':']', '{':'}',"'":"'",'"':'"'}

" undotree
let g:undotree_DiffAutoOpen = 0
let g:undotree_SetFocusWhenToggle = 1
nnoremap U <CMD>UndotreeToggle<CR>

" easymotion
" <Leader>f{char} to move to {char}
map  <Leader>m <Plug>(easymotion-bd-f)
nmap <Leader>m <Plug>(easymotion-overwin-f)
" s{char}{char} to move to {char}{char}
nmap s <Plug>(easymotion-overwin-f2)
" Move to line
map  <Leader>L <Plug>(easymotion-bd-jk)
nmap <Leader>L <Plug>(easymotion-overwin-line)
" Move to word
map  <Leader>w <Plug>(easymotion-bd-w)
nmap <Leader>w <Plug>(easymotion-overwin-w)

" float term
let g:floaterm_height=0.4
let g:floaterm_wintype="split"
nnoremap <silent> <C-_> <CMD>FloatermToggle<CR>
tnoremap <silent> <C-_> <C-\><C-n><CMD>FloatermToggle<CR>
nnoremap <silent> <leader>gg <CMD>FloatermNew --width=0.8 --height=0.8 --wintype='float' lazygit<CR>
" no need to confirm before exit vim
autocmd ExitPre * :FloatermKill<CR>

" vimcomplete


" ale
let g:ale_fixers = {
\   'javascript': ['prettier', 'eslint']
\}
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['eslint'],
\}
let g:ale_fix_on_save = 1
