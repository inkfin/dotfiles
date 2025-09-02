" nerdtree
if !exists("g:explorer_type") || g:explorer_type == "nerdtree"

Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'ryanoasis/vim-devicons'

let g:nERDTreeFileLines = 1
let g:NERDTreeChDirMode = 2 " change cwd when tab changes
nnoremap <silent> <leader>e <CMD>NERDTreeToggle<CR>
nnoremap <silent> <leader>E <CMD>ProjectRootExe NERDTreeFind<CR>

else

Plug 'tpope/vim-vinegar'

endif
