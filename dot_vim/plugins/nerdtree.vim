" nerdtree
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'ryanoasis/vim-devicons'

let g:nERDTreeFileLines = 1
let g:NERDTreeChDirMode = 2 " change cwd when tab changes
nnoremap <silent> <leader>e <CMD>NERDTreeToggle<CR>
nnoremap <silent> <leader>E <CMD>ProjectRootExe NERDTreeFind<CR>


" find project root
Plug 'dbakker/vim-projectroot'

let g:rootmarkers = ['.projectroot', '.root','.git', '.jj','.hg','.svn',
            \ '.vscode', '.vs', '.vim', '.idea']
nnoremap <expr> <leader>ep ':edit '.projectroot#guess().'/'

" automatically change cwd to project root
function! <SID>AutoProjectRootCD()
    try
        if &ft != 'help'
            ProjectRootCD
        endif
    catch
        " silently ignore invalid buffers
    endtry
endfunction

autocmd BufEnter * call <SID>AutoProjectRootCD()

