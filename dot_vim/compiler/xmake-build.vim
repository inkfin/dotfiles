" Vim compiler file
" Compiler:		xmake

if exists("current_compiler")
    finish
endif
let current_compiler = "xmake-build"

let s:cpo_save = &cpo
set cpo&vim

" example error messages:
"error: ./xmake.lua:3: attempt to call a nil value (global 'add_cxflag')
"stack traceback:
"    [./xmake.lua:3]: in main chunk
"
"error: ./xmake.lua:3: attempt to call a nil value (global 'add_cxflag')
"stack traceback:
"    [./xmake.lua:3]: in main chunk
CompilerSet errorformat=
    \%trror:\ %f:%l:\ %m,
    \%Aerror:\ %f:%l:%c:\ %t%*[^:]:\ %m,
    \%A%f:%l:%c:\ %t%*[^:]:\ %m,
    \%Z,
    \%-G%.%#,

let &cpo = s:cpo_save
unlet s:cpo_save

CompilerSet makeprg=XMAKE_COLORTERM=nocolor\ xmake\ b
