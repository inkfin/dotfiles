" find project root
Plug 'dbakker/vim-projectroot'

let g:rootmarkers = ['.projectroot', '.git', '.jj', '.hg','.svn',
            \ '.root', '.vscode', '.vs', '.vim', '.idea']
nnoremap <expr> <leader>ep ':edit '.projectroot#guess().'/'

" automatically change cwd to project root
function! <SID>AutoProjectRootCD()
    try
        if &ft != 'help' && &ft != 'floaterm'
            ProjectRootCD
        endif
    catch
        " silently ignore invalid buffers
    endtry
endfunction

autocmd BufEnter * call <SID>AutoProjectRootCD()

