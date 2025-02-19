""""""""""""""""""""
" Keymaps
""""""""""""""""""""

let g:mapleader = " "
let g:maplocalleader = ","

" Jump to matching pairs easily in normal mode
nnoremap <Tab> %

" Paste over currently selected text without yanking it
vnoremap <silent> p "_dP

vnoremap <silent> H ^
vnoremap <silent> L $
noremap <silent> W 5w
noremap <silent> B 5b
noremap <silent> E 5e

" Navigate between windows
nnoremap <silent> <C-H> <C-w>h
nnoremap <silent> <C-J> <C-w>j
nnoremap <silent> <C-K> <C-w>k
nnoremap <silent> <C-L> <C-w>l

" Resize windows using <Alt> and arrow keys, inspiration from
" https://vim.fandom.com/wiki/Fast_window_resizing_with_plus/minus_keys (bottom page).
nnoremap <silent> <M-left> <C-w><
nnoremap <silent> <M-right> <C-w>>
nnoremap <silent> <M-down> <C-W>-
nnoremap <silent> <M-up> <C-W>+

" navigate between buffers & tabs
nnoremap <silent> H <CMD>bp<CR>
nnoremap <silent> L <CMD>bn<CR>
nnoremap <silent> <leader>bd <CMD>bd<CR>
nnoremap <silent> ]t <CMD>tabn<CR>
nnoremap <silent> [t <CMD>tabp<CR>

nnoremap <leader>\| :vs<CR>
nnoremap <leader>- :sp<CR>

nnoremap Q :q<CR>
map <C-S> :w<CR>


nnoremap <silent> <leader>h K

" When completion menu is shown, use <cr> to select an item
" and do not add an annoying newline. Otherwise, <enter> is what it is.
" For more info , see https://superuser.com/q/246641/736190 and
" https://unix.stackexchange.com/q/162528/221410
inoremap <expr> <cr> ((pumvisible())?("\<C-Y>"):("\<cr>"))
" Use <esc> to close auto-completion menu
"inoremap <expr> <esc> ((pumvisible())?("\<C-e>"):("\<esc>"))

" Use <tab> to navigate down the completion menu.
inoremap <expr> <tab>  pumvisible()?"\<C-n>":"\<tab>"


" Edit and reload init.vim quickly
nnoremap <silent> <leader>ov :edit $MYVIMRC<cr>
nnoremap <silent> R :silent update $MYVIMRC <bar> source $MYVIMRC <bar>
    \ echomsg "Nvim config successfully reloaded!"<cr>

" Continuous visual shifting (does not exit Visual mode), `gv` means
" to reselect previous visual area, see https://superuser.com/q/310417/736190
xnoremap <silent> < <gv
xnoremap <silent> > >gv

" Decrease indent level in insert mode with shift+tab
inoremap <S-Tab> <ESC><<i

" Use Esc to quit builtin terminal
if exists(':tnoremap')
    tnoremap <ESC>   <C-\><C-n>
endif

" Clear highlighting
nnoremap <silent> <leader><enter> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>

" lazygit
nnoremap <silent> <leader>gg :!lazygit<CR>
