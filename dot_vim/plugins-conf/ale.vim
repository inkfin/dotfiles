" ale

if g:diag_backend !=# "ale"
    finish
endif

""""""""""""""""""""
" LINTERS
""""""""""""""""""""

let g:ale_echo_cursor  = 1 " show err in echo
let g:ale_hover_cursor = 0 " show type info in echo
if !exists('textprop') " no virtual-text
    let g:ale_virtualtext_cursor = 1  " virtual text
endif
" show info in balloons
let g:ale_floating_preview = 1
let g:ale_hover_to_floating_preview = 1

" avoid searching for executable locally (which is slow)
let g:ale_use_global_executables = get(g:, 'ale_use_global_executables', 1)
" avoid stuck when editing files by only lint on save
let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_save = 1

" disable all other linters
let g:ale_linters_explicit = get(g:, 'ale_linters_explicit', 1)
" allow local.vim overrride
let g:ale_linters = get(g:, 'ale_linters', {})
call extend(g:ale_linters, {
\   'javascript': ['eslint'],
\   'c':   ['cc', 'clangd', 'clangtidy'],
\   'cpp': ['cc', 'clangd', 'clangtidy'],
\   'python': ['ruff', 'pyright'],
\}, 'keep')

" cc options
let g:ale_c_cc_options = '-std=c11 -Wall -Wextra'
let g:ale_cpp_cc_options = '-std=c++20 -Wall -Wextra'


""""""""""""""""""""
" FIXERS
""""""""""""""""""""

let g:ale_fixers = get(g:, 'ale_fixers', {})
call extend(g:ale_fixers, {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['prettier', 'eslint'],
\   'c':   ['clang-format', 'clangtidy'],
\   'cpp': ['clang-format', 'clangtidy'],
\   'python': ['ruff'],
\   'lua': ['luafmt'],
\}, 'keep')

" clang-format
let g:ale_c_clangformat_use_local_file = 1


""""""""""""""""""""
" COMPLETIONS
""""""""""""""""""""

let g:ale_fix_on_save = 0
" show omnifunc completion while typing
let g:ale_completion_enabled = get(g:, 'ale_completion_enabled', 1)
" import completion results from external modules
let g:ale_completion_autoimport = 1
let g:ale_list_window_size = 5

" set linter name aliases
let g:ale_linter_aliases = get(g:, 'ale_linter_aliases', {})
call extend(g:ale_linter_aliases, {
\   'Dockerfile': 'dockerfile',
\   'bash': 'sh',
\   'csh': 'sh',
\   'javascriptreact': ['javascript', 'jsx'],
\   'plaintex': 'tex',
\   'ps1': 'powershell',
\   'rmarkdown': 'r',
\   'rmd': 'r',
\   'systemverilog': 'verilog',
\   'typescriptreact': ['typescript', 'tsx'],
\   'vader': ['vim', 'vader'],
\   'verilog_systemverilog': ['verilog_systemverilog', 'verilog'],
\   'vimwiki': 'markdown',
\   'vue': ['vue', 'javascript'],
\   'xsd': ['xsd', 'xml'],
\   'xslt': ['xslt', 'xml'],
\   'zsh': 'sh',
\}, 'keep')

" only register ale omnifunc in some languages, triggered with <C-x><C-o>
augroup AleOmni
  autocmd!
  autocmd FileType * call s:AleSetOmni()
augroup END

function! s:AleSetOmni() abort
    let loaded_ale = get(g:, 'loaded_ale', 0) " ale internal flag
    let ft_mapped = get(g:ale_linter_aliases, &filetype, &filetype)
    let ft_enabled = has_key(g:ale_linters, ft_mapped)
    if loaded_ale && ft_enabled
        setlocal omnifunc=ale#completion#OmniFunc
    endif
endfunction


""""""""""""""""""""
" KEYMAPS
""""""""""""""""""""

nmap     <silent> K          <CMD>ALEHover<CR>
nmap     <silent> gd         <CMD>ALEGoToDefinition<CR>
nmap     <silent> gr         <CMD>ALEFindReferences<CR>
nmap     <silent> <leader>ca <CMD>ALECodeAction<CR>
nmap     <silent> <leader>rn <CMD>ALERename<CR>
nmap     <silent> <leader>rf <CMD>ALEFix<CR>

" diagnostic
nmap     <silent> <leader>dd <Plug>(ale_detail)

imap     <silent> <C-Space>  <Plug>(ale_complete)
imap     <silent> <C-@>      <Plug>(ale_complete)


function! ALESearchSymbolPrompt()
    let l:sym = input("SymbolToSearch: ")
    if !empty(l:sym)
        execute "ALESymbolSearch " . l:sym
    endif
endfunction

nnoremap <silent> <leader>ss <CMD>call ALESearchSymbolPrompt()<CR>

nnoremap <silent> <leader>ud <CMD>ALEToggle<CR>
nnoremap <silent> <leader>uD <CMD>ALEToggleBuffer<CR>
nnoremap          <leader>uf <CMD>let g:ale_fix_on_save = get(g:, 'ale_fix_on_save', 0) ? 0 : 1 \| echo "[Global]ALE Fix on Save: " . g:ale_fix_on_save<CR>
nnoremap          <leader>uF <CMD>let b:ale_fix_on_save = get(b:, 'ale_fix_on_save', 0) ? 0 : 1 \| echo "[Buffer]ALE Fix on Save: " . b:ale_fix_on_save<CR>

nmap     <silent> [d         <Plug>(ale_previous_wrap)
nmap     <silent> ]d         <Plug>(ale_next_wrap)


""""""""""""""""""""
" APPEARANCE
""""""""""""""""""""

let g:ale_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰', '│', '─']
let g:ale_sign_column_always = 1
let g:ale_echo_msg_format = '[%linter%] (%code) %%s [%severity%]'

if get(g:, "use_nerdfont", 0)
    let g:ale_sign_error         = '✘'
    let g:ale_sign_warning       = '▲'
    let g:ale_sign_info          = '●'
    let g:ale_sign_style_error   = '✎'
    let g:ale_sign_style_warning = '✎'
    let g:ale_echo_msg_error_str   = ''
    let g:ale_echo_msg_warning_str = ''
    let g:ale_echo_msg_info_str    = ''

    let g:ale_completion_symbols = {
    \ 'text':          '',
    \ 'method':        '󰆧',
    \ 'function':      '󰊕',
    \ 'constructor':   '󰆧',
    \ 'field':         '󰜢',
    \ 'variable':      '󰀫',
    \ 'class':         '󰠱',
    \ 'struct':        '󰙅',
    \ 'interface':     '󰜰',
    \ 'module':        '󰆧',
    \ 'property':      '󰜢',
    \ 'unit':          '󰑭',
    \ 'value':         '󰎠',
    \ 'enum':          '󰕘',
    \ 'enum_member':   '󰕘',
    \ 'constant':      '󰏿',
    \ 'keyword':       '󰌋',
    \ 'snippet':       '󰅩',
    \ 'color':         '󰏘',
    \ 'file':          '󰈙',
    \ 'folder':        '󰉋',
    \ 'reference':     '󰈇',
    \ 'event':         '󰉁',
    \ 'operator':      '󰆕',
    \ 'type_parameter':'󰊄',
    \ '<default>':     ''
    \ }
else
    let g:ale_sign_error         = '>>'
    let g:ale_sign_warning       = '++'
    let g:ale_sign_info          = '~~'
    let g:ale_sign_style_error   = 'S'
    let g:ale_sign_style_warning = 's'
    let g:ale_echo_msg_error_str   = 'E'
    let g:ale_echo_msg_warning_str = 'W'
    let g:ale_echo_msg_info_str    = 'I'

    let g:ale_completion_symbols = {
    \ 'function':      'f',
    \ 'method':        'm',
    \ 'variable':      'v',
    \ 'field':         'f',
    \ 'class':         'C',
    \ 'struct':        'S',
    \ 'enum':          'E',
    \ 'enum_member':   'e',
    \ 'constant':      'K',
    \ 'module':        'M',
    \ 'keyword':       'k',
    \ 'file':          'F',
    \ 'folder':        'D',
    \ '<default>':     '?'
    \ }
endif

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

