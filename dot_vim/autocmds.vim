""""""""""""""""""""
""" Autocmd
""""""""""""""""""""

" Run chezmoi apply whenever a dotfile is saved
autocmd BufWritePost ~/.local/share/chezmoi/* ! chezmoi apply --source-path "%"

" Change transparency of the terminal
augroup TransparentBG
  autocmd!
  autocmd ColorScheme * hi Normal       ctermbg=NONE guibg=NONE
  autocmd ColorScheme * hi NormalFloat  ctermbg=NONE guibg=NONE
  autocmd ColorScheme * hi SignColumn   ctermbg=NONE guibg=NONE
  autocmd ColorScheme * hi LineNr       ctermbg=NONE guibg=NONE
augroup END
