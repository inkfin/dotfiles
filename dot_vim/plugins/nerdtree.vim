" nerdtree
if !exists("g:explorer_type") || g:explorer_type == "nerdtree"

Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'ryanoasis/vim-devicons'

let g:nERDTreeFileLines = 1
let g:NERDTreeChDirMode = 2 " change cwd when tab changes
nunmap <silent> <leader>e
nnoremap <silent> <leader>e <CMD>NERDTreeToggle<CR>
nnoremap <silent> <leader>E <CMD>ProjectRootExe NERDTreeFind<CR>

endif

" always include vim-vinegar to enhance open folders experience
Plug 'tpope/vim-vinegar'
