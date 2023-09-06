""" tex.vim -- LaTex specific settings
""" Commentary:
""" LaTex in Vim using [VimTex](https://github.com/lervag/vimtex)
""" |======|=========================|======|
""" | LHS  |           RHS           | MODE |
""" |======|=========================|======|
""" | dse  | delete-surrounding-env  |  n   |
""" | dsc  | delete-surrounding-cmd  |  n   |
""" | dsm  | delete-surrounding-math |  n   |
""" | cse  | change-surrounding-env  |  n   |
""" | csc  | change-surrounding-cmd  |  n   |
""" | csm  | change-surrounding-math |  n   |
""" | tse  | toggle-surrounding-env  |  n   |
""" | tsd  | toggle-delim-modifier   |  nx  |
""" | <F7> | create-cmd-inplace      |  ni  |
""" | ]]   | insert-close-delim      |  i   |
""" |======|=========================|======|
"""
""" Code:

let s:key_map = {}

" ===
" === lervag/vimtex
" ===
let g:tex_flavor='latex'
" let g:tex_conceal='adbmg'
let g:vimtex_compiler_progname='nvr'
if has('mac')
    let g:vimtex_view_method='skim'
    let g:vimtex_view_general_viewer='open -a /Applications/Skim.app '
    let g:vimtex_view_skim_sync = 1
    let g:vimtex_view_skim_activate = 1
    let g:vimtex_view_skim_reading_bar = 1
endif
let g:vimtex_quickfix_mode = 0 "quickfix auto pop up
let g:vimtex_quickfix_ignore_filters = [
      \ 'does not contain requested Script',
      \]

" Disable imaps
let g:vimtex_imaps_enabled = 0
" let g:vimtex_view_automatic = 0

imap <buffer> <f7> <plug>(vimtex-cmd-create)}<left>

nnoremap dsm <Plug>(vimtex-env-delete-math)
nnoremap csm <Plug>(vimtex-cmd-change-math)

" Use `ai` and `ii` for the item text object
xmap ii <Plug>(vimtex-im)
omap ii <Plug>(vimtex-im)
xmap ai <Plug>(vimtex-am)
omap ai <Plug>(vimtex-am)

" Use `am` and `im` for the inline math text object
xmap im <Plug>(vimtex-i$)
omap im <Plug>(vimtex-i$)
xmap am <Plug>(vimtex-a$)
omap am <Plug>(vimtex-a$)


nnoremap <localleader>t <Plug>(vimtex-toc-toggle)
let s:key_map.t = "toggle-TOC"

nnoremap <localleader>e <Plug>(vimtex-errors)
let s:key_map.e = "show-errors"

nnoremap <localleader>c <Cmd>write<CR><Cmd>VimtexCompile<CR>
let s:key_map.c = "compile"

"" Performe forward-search
nnoremap <localleader>f <Cmd>VimtexView<CR>
let s:key_map.f = "sync-PDF"

"" NOTE: To perform reverse-search, <cmd+S>+<LeftClick> in the PDF Reader


nnoremap <localleader>r <Plug>(vimtex-reload)
let s:key_map.r = "reload"

nnoremap <localleader>wc <Cmd>VimtexCountWords<CR>
let s:key_map.w = { "name" : "+word-count", "c" : "word-count" }

""" o: +open
nnoremap <localleader>oi <Plug>(vimtex-info)
nnoremap <localleader>oI <Plug>(vimtex-info-full)
nnoremap <localleader>ot <Plug>(vimtex-toc-open)
nnoremap <localleader>os <Plug>(vimtex-status)
nnoremap <localleader>oS <Plug>(vimtex-status-all)
let s:key_map.o = {
    \ "name" : "+open",
    \ "i" : "info",
    \ "I" : "info-full",
    \ "t" : "toc",
    \ "s" : "status",
    \ "S" : "status-all"
    \ }

""" l: list
let s:key_map.l = { "name" : "+list" }
nnoremap <localleader>lm <Plug>(vimtex-imaps-list)
let s:key_map.l.m = "imap-list"

""" p: plugins
let s:key_map.p = { "name" : "+plug-settings" }

nnoremap <localleader>pk <Plug>(vimtex-stop)
let s:key_map.p.k = "stop-vimtex"
nnoremap <localleader>pK <Plug>(vimtex-stop-all)
let s:key_map.p.K = "stop-all-vimtex"
nnoremap <localleader>pc <Plug>(vimtex-clean)
let s:key_map.p.c = "clean-files"
nnoremap <localleader>pC <Plug>(vimtex-clean-full)
let s:key_map.p.C = "clean-files-full"



" augroup vimtex_buf_key_map
    " au!
    " au BufEnter *.tex call s:SetWhichKeyLocalBinding()
    " au BufLeave *.tex call s:UnsetWhichKeyLocalBinding()
" augroup END

autocmd BufEnter *.tex call s:SetWhichKeyLocalBinding() | au! User vim-which-key call which_key#register(',', "g:which_key_map_local")
autocmd BufLeave *.tex call s:UnsetWhichKeyLocalBinding() | au! User vim-which-key call which_key#register(',', "g:which_key_map_local")


function! s:SetWhichKeyLocalBinding() abort
    let g:keep_mapping = get(g:, 'keep_mapping', deepcopy(g:which_key_map_local))
    let g:which_key_map_local = s:key_map
endfunction

function! s:UnsetWhichKeyLocalBinding() abort
    let g:which_key_map_local = g:keep_mapping
endfunction

augroup vimtex_event_focus
    au!
    au User VimtexEventViewReverse call s:TexFocusVim()
    au User VimtexEventView call s:TexFocusVim()
augroup END

function! s:TexFocusVim() abort
    if exists("g:neovide")
        silent execute "!open -a Neovide"
    else
        silent execute "!open -a iTerm"
    endif
    redraw!
endfunction

""" tex.vim ends here

