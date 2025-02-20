" nerdtree
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'ryanoasis/vim-devicons'

let g:nERDTreeFileLines = 1
let g:NERDTreeChDirMode = 2 " change cwd when tab changes
nnoremap <silent> <leader>e <CMD>NERDTreeToggle<CR>
nnoremap <silent> <leader>E <CMD>ProjectRootExe NERDTreeFind<CR>


