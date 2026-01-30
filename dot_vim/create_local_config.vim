""" vim's local config that won't be tracked

" theme
let g:transparent = 0
let g:use_nerdfont = 1

" edit
"let g:use_system_clipboard = 1

" diagnostic backend
"  'ale'|'ctags'|'lsp'|'vimcomplete'
let g:diag_backend = "ale"

"" override configs
"" ale
" auto display completion (sometimes annoying)
"let g:ale_completion_enabled = 0
let g:ale_linters = {}
let g:ale_fixers = {}

" file explorer style
"  'nerdtree'|'netrw'
let g:explorer_type="nerdtree"

" AI
let g:enable_AI = 0

" Plugins switch on/off
"  let g:disable_plugin_{name} = v:true

