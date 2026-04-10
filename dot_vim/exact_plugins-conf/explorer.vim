" explorer

if g:explorer_type ==# "nerdtree"

let g:nERDTreeFileLines = 1
let g:NERDTreeChDirMode = 2 " change cwd when tab changes
nunmap <silent> <leader>e
nnoremap <silent> <leader>e <CMD>NERDTreeToggle<CR>
nnoremap <silent> <leader>E <CMD>ProjectRootExe NERDTreeFind<CR>

endif

