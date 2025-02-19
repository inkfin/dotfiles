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

highlight ALEWarning ctermbg=DarkMagenta

nnoremap K <CMD>ALEHover<CR>
nnoremap gd <CMD>ALEGoToDefinition<CR>
nnoremap gr <CMD>ALEFindReferences<CR>
nnoremap <leader>ca <CMD>ALECodeAction<CR>
nnoremap <leader>rn <CMD>ALERename<CR>
nnoremap <leader>rf <CMD>ALEFix<CR>

