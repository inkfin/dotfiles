" terminal & float window

if !PluginDisabled("floaterm")

let g:floaterm_height=0.4
let g:floaterm_wintype="split"
nnoremap <silent> <C-_> <CMD>FloatermToggle<CR>
tnoremap <silent> <C-_> <C-\><C-n><CMD>FloatermToggle<CR>
nnoremap <silent> <C-/> <CMD>FloatermToggle<CR>
tnoremap <silent> <C-/> <C-\><C-n><CMD>FloatermToggle<CR>
" lazygit
nnoremap <silent> <leader>gg <CMD>FloatermNew --width=0.8 --height=0.8 --wintype='float' lazygit<CR>
" yazi
nnoremap <silent> <leader>ff <CMD>FloatermNew --width=0.8 --height=0.8 --wintype='float' yazi<CR>
nnoremap <silent> <leader>yy <CMD>FloatermNew --width=0.8 --height=0.8 --wintype='float' yazi<CR>
" no need to confirm before exit vim
autocmd ExitPre * silent! FloatermKill<CR>

endif
