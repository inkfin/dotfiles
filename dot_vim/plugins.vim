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
" plug self
Plug 'junegunn/vim-plug'

runtime! plugins-decl/*.vim

call plug#end()

runtime! plugins-conf/*.vim
