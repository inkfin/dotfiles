" statusline

if !PluginDisabled("airline")

let g:airline_theme='angr'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
if get(g:, 'use_nerdfont', 0)
    let g:airline_powerline_fonts = 1
endif

" don't show spell language
let g:airline_detect_spelllang=0

endif

