" fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

let g:fzf_vim = {}
let g:fzf_vim.buffers_jump = 1
let g:fzf_vim.preview_window = ['right,50%,<70(up,40%)', 'ctrl-l']
let g:fzf_action = {
\   'ctrl-t': 'tab split',
\   'ctrl-x': 'split',
\   'ctrl-v': 'vsplit',
\}
nnoremap <leader><leader> <CMD>Files<CR>
nnoremap <leader>/ <CMD>Rg<CR>
nnoremap <leader>sm <CMD>Marks<CR>
nnoremap <leader>sh <CMD>Helptags<CR>
nnoremap <leader>sc <CMD>Commands<CR>
nnoremap <leader>sb <CMD>Buffers<CR>
nnoremap <leader>sr <CMD>History<CR>
nnoremap <leader>sw <CMD>Windows<CR>

