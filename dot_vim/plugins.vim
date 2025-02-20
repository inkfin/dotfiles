""""""""""""""""""""
""" Plugins
""""""""""""""""""""

" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugin configurations

call plug#begin()

" plug self
Plug 'junegunn/vim-plug'

Plug 'habamax/vim-habamax'

for f in glob('~/.vim/plugins/*.vim', 0, 1)
    execute 'source' f
endfor

call plug#end()

