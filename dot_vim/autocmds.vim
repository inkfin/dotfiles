""""""""""""""""""""
""" Autocmd
""""""""""""""""""""

" Run chezmoi apply whenever a dotfile is saved
if !get(g:, 'minimal_vimrc', 0)
    autocmd BufWritePost ~/.local/share/chezmoi/* ! chezmoi apply --source-path "%"
endif

if get(g:, 'transparent', 0)
    " Change transparency of the terminal
    augroup TransparentColorscheme
        autocmd!
        autocmd ColorScheme * highlight Normal  ctermbg=None guibg=NONE
        "autocmd ColorScheme * highlight Comment ctermfg=DarkGrey ctermbg=Black guifg=#a8a8a8 guibg=#1b1b1b
        autocmd ColorScheme * hi NormalFloat  ctermbg=NONE guibg=NONE
        autocmd ColorScheme * hi SignColumn   ctermbg=NONE guibg=NONE
        autocmd ColorScheme * hi LineNr       ctermbg=NONE guibg=NONE

    augroup END
endif

" Disable spell highlight
augroup SpellHighlight
    autocmd!
        autocmd ColorScheme * highlight clear SpellCap
        autocmd ColorScheme * highlight clear SpellRare
        autocmd ColorScheme * highlight clear SpellLocal
        autocmd ColorScheme * highlight SpellBad
            \ cterm=underline ctermfg=NONE ctermbg=NONE
            \ gui=undercurl guifg=NONE guibg=NONE
augroup END

