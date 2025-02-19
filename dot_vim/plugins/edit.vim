" completion of delimiter
Plug 'jiangmiao/auto-pairs'

let g:AutoPairsMapCh = 0
let g:AutoPairs= {'(':')', '[':']', '{':'}',"'":"'",'"':'"'}


" vim-surround
Plug 'tpope/vim-surround'

" tutorials: <https://github.com/tpope/vim-surround>


" comment line
Plug 'scrooloose/nerdcommenter'

let g:NERDCreateDefaultMappings = 0
let g:NERDCommentEmptyLines = 0
let g:NERDToggleCheckAllLines = 0
let g:NERDCustomDelimiters = {
\    'c': { 'left': '//' }
\}
nmap gcc <Plug>NERDCommenterToggle
vmap gc <Plug>NERDCommenterToggle


" navigate
Plug 'easymotion/vim-easymotion'

map \\ <Plug>(easymotion-prefix)
" <Leader>f{char} to move to {char}
map  <Leader>m <Plug>(easymotion-bd-f)
nmap <Leader>m <Plug>(easymotion-overwin-f)
" s{char}{char} to move to {char}{char}
nmap s <Plug>(easymotion-overwin-f2)
" Move to line
map  <Leader>L <Plug>(easymotion-bd-jk)
nmap <Leader>L <Plug>(easymotion-overwin-line)
" Move to word
map  <Leader>w <Plug>(easymotion-bd-w)
nmap <Leader>w <Plug>(easymotion-overwin-w)

