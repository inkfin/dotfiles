" fzf
"
" Rules:
" |  foo        | smart          |
" |  Foo        | case-sensitive |
" |  !foo       | 反向匹配       |
" |  ^foo       | 以 foo 开头    |
" |  bar$       | 以 bar 结尾    |
" |  'foo       | 精确子串       |
" |  foo bar    | AND (同时包含) |
" |  foo | bar  |  OR            |
"


if !PluginDisabled("fzf")

let g:fzf_vim = {}
let g:fzf_vim.buffers_jump = 1
let g:fzf_vim.preview_window = ['right,50%,<70(up,40%)', 'ctrl-l']
let g:fzf_action = {
\   'ctrl-t': 'tab split',
\   'ctrl-h': 'split',
\   'ctrl-v': 'vsplit',
\}

nmap     <silent> <leader><leader> <CMD>Files<CR>
nmap     <silent> <leader>ff <CMD>Files<CR>
nmap     <silent> <leader>/  <CMD>Rg<CR>
nmap     <silent> <leader>sm <CMD>Marks<CR>
nmap     <silent> <leader>sh <CMD>Helptags<CR>
nmap     <silent> <leader>sc <CMD>Commands<CR>
nmap     <silent> <leader>sb <CMD>Buffers<CR>
nmap     <silent> <leader>sr <CMD>History<CR>
nmap     <silent> <leader>sw <CMD>Windows<CR>

" fix fzf twindow exit to normal mode
"tmap     <expr>   <Esc>      (&filetype == "fzf") ? "<Esc>" : "<c-\><c-n>"

endif
