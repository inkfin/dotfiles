""""""""""""""""""""
""" Autocmd
""""""""""""""""""""

" Run chezmoi apply whenever a dotfile is saved
autocmd BufWritePost ~/.local/share/chezmoi/* ! chezmoi apply --source-path "%"

