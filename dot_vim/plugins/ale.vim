" ale

if v:version >= 900 && !g:force_use_ale
    finish
endif
let use_ale = 1

let g:ale_completion_enabled = 1
Plug 'dense-analysis/ale'

let g:ale_fixers = {
    \ 'javascript': ['prettier', 'eslint'],
    \ 'cpp': ['clangd'],
    \ }
let g:ale_fixers = {
    \ '*': ['remove_trailing_lines', 'trim_whitespace'],
    \ 'javascript': ['eslint'],
    \ 'cpp': ['clang-format', 'clangtidy'],
    \ }

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

augroup ALEColorschemePreferences
  autocmd!
    autocmd ColorScheme * highlight MatchParen cterm=bold ctermfg=cyan gui=bold guifg=cyan guibg=black
    autocmd ColorScheme * highlight ALEErrorSign cterm=bold ctermfg=red gui=bold guifg=red
    autocmd ColorScheme * highlight ALEVirtualTextError cterm=italic ctermfg=magenta gui=italic guifg=red
    autocmd ColorScheme * highlight ALEWarningSign cterm=bold ctermfg=yellow gui=bold guifg=yellow
    autocmd ColorScheme * highlight ALEVirtualTextWarning cterm=italic ctermfg=yellow gui=italic guifg=yellow
    autocmd ColorScheme * highlight ALEInfoSign cterm=bold ctermfg=white gui=bold guifg=white
augroup END

nmap <silent> K <CMD>ALEHover<CR>
nmap <silent> gd <CMD>ALEGoToDefinition<CR>
nmap <silent> gr <CMD>ALEFindReferences<CR>
nmap <silent> <leader>ca <CMD>ALECodeAction<CR>
nmap <silent> <leader>rn <CMD>ALERename<CR>
nmap <silent> <leader>rf <CMD>ALEFix<CR>

nmap <silent> <leader>ud <CMD>ALEToggle<CR>
nmap <silent> <leader>uD <CMD>ALEToggleBuffer<CR>
nnoremap <leader>uf <CMD>let g:ale_fix_on_save = get(g:, 'ale_fix_on_save', 0) ? 0 : 1 \| echo "[Global]ALE Fix on Save: " . g:ale_fix_on_save<CR>
nnoremap <leader>uF <CMD>let b:ale_fix_on_save = get(b:, 'ale_fix_on_save', 0) ? 0 : 1 \| echo "[Buffer]ALE Fix on Save: " . b:ale_fix_on_save<CR>

nmap <silent> [d <Plug>(ale_previous_wrap)
nmap <silent> ]d <Plug>(ale_next_wrap)

