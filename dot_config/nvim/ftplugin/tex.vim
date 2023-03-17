"" tex.vim -- LaTex specific settings
"" Commentary:
"" LaTex in Vim using [VimTex](https://github.com/lervag/vimtex)

"" Code:

"" Config:
let s:key_map = {}

" ===
" === lervag/vimtex
" ===
let g:tex_flavor='latex'
let g:vimtex_compiler_progname='nvr'
let g:vimtex_quickfix_mode=0 "disable quickfix auto pop up
if has('mac')
let g:vimtex_view_method='skim'
endif
let g:vimtex_view_skim_reading_bar=1
let g:vimtex_view_general_viewer=''
let g:tex_conceal='adbmg'


nnoremap dsm <Plug>(vimtex-env-delete-math)
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


nnoremap <localleader>e <Plug>(vimtex-toc-toggle)
let s:key_map.e = "toggle-TOC"

nnoremap <localleader>2 <Plug>(vimtex-view)
let s:key_map.2 = "sync-PDF"
nnoremap <localleader>1 <Plug>(vimtex-reverse-search)
let s:key_map.1 = "sync-VIM"

nnoremap <localleader>c <Cmd>write<CR><Cmd>VimtexCompile<CR>
let s:key_map.c = "compile"

nnoremap <localleader>r <Plug>(vim-reload)
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
nnoremap <localleader>le <Plug>(vimtex-errors)
let s:key_map.l.e = "errors"
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

""" t: toggle
let s:key_map.t = { "name" : "+toggle" }
nnoremap <localleader>tm <Plug>(vimtex-toggle-main)
let s:key_map.t.m = "main-tex-file"


autocmd BufEnter *.tex call g:SetWhichKeyLocalBinding()
autocmd BufLeave *.tex call g:UnsetWhichKeyLocalBinding()

function! g:SetWhichKeyLocalBinding()
    let s:keep_mapping = get(s:, 'keep_mapping', deepcopy(g:which_key_map_local))
    let g:which_key_map_local = s:key_map
endfunction

function! g:UnsetWhichKeyLocalBinding()
    let g:which_key_map_local = s:keep_mapping
endfunction

"" tex.vim ends here
