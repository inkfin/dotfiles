" ale

if (v:version >= 910)
    finish
endif

let g:ale_completion_enabled = 1
Plug 'dense-analysis/ale'

let g:ale_fixers = {
\   'javascript': ['prettier', 'eslint'],
\   'cpp': ['clangd'],
\}
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['eslint'],
\   'cpp': ['clang-format', 'clangtidy'],
\}

let g:ale_cpp_cc_options = '-std=c++20 -Wall -Wextra'

let g:ale_fix_on_save = 0
let g:ale_completion_autoimport = 1
let g:ale_list_window_size = 5

let g:ale_hover_cursor = 1
let g:ale_echo_cursor=1
let g:ale_floating_preview = 1
let g:ale_hover_to_floating_preview = 1
let g:ale_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰', '│', '─']

let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] (%code) %%s [%severity%]'

" enable airline support
let g:airline#extensions#ale#enabled = 1

highlight ALEErrorSign ctermbg=DarkMagenta ctermfg=red
highlight ALEError ctermfg=red cterm=underline
highlight ALEWarning ctermfg=yellow cterm=underline

nmap <silent> K <CMD>ALEHover<CR>
nmap <silent> gd <CMD>ALEGoToDefinition<CR>
nmap <silent> gr <CMD>ALEFindReferences<CR>
nmap <silent> <leader>ca <CMD>ALECodeAction<CR>
nmap <silent> <leader>rn <CMD>ALERename<CR>
nmap <silent> <leader>rf <CMD>ALEFix<CR>

nmap <silent> [d <Plug>(ale_previous_wrap)
nmap <silent> ]d <Plug>(ale_next_wrap)

