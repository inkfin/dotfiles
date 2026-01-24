""""""""""""""""""""
""" Plugins
""""""""""""""""""""

" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

let g:diag_backend = get(g:, "diag_backend", "none")
let g:explorer_type = get(g:, "explorer_type", "nerdtree")

" Global disable helper funcitons
function! PluginDisabled(name) abort
    return exists('g:plugin_disable_' . a:name)
endfunction

" Plugin configurations

call plug#begin()
"" plug self
Plug 'junegunn/vim-plug'


"" theme
Plug 'habamax/vim-habamax'

"" statusline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'


"" LSP client
if g:diag_backend ==# "ale"

    Plug 'dense-analysis/ale'

elseif g:diag_backend ==# "lsp"

    Plug 'yegappan/lsp'

elseif g:diag_backend ==# "vimcomplete"

    Plug 'girishji/vimcomplete'

endif


"" edit.vim
""  completion of delimiter
""  its too basic and always needed

Plug 'jiangmiao/auto-pairs'

Plug 'tpope/vim-surround'

" comment line
Plug 'scrooloose/nerdcommenter'

" navigate
Plug 'easymotion/vim-easymotion'

" highlighter
Plug 'rrethy/vim-illuminate'

" undo Tree
Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }

" indentLine
Plug 'Yggdroot/indentLine'

" easy align
Plug 'junegunn/vim-easy-align'

" find project root
Plug 'dbakker/vim-projectroot'


"" explorer

if g:explorer_type ==# "nerdtree"

    Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
    Plug 'ryanoasis/vim-devicons'

endif

" always include vim-vinegar to enhance open folders experience
Plug 'tpope/vim-vinegar'


"" terminal & float window
if !PluginDisabled("floaterm")

    Plug 'voldikss/vim-floaterm'

endif


"" fzf
if !PluginDisabled("fzf")

    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'

endif


"" any-jump with rg or ag
if !PluginDisabled("any-jump")

    Plug 'pechorin/any-jump.vim'

endif


call plug#end()

runtime! plugins-conf/*.vim
