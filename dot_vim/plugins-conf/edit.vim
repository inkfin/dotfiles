" completion of delimiter
"  its too basic and always needed


" auto-pairs
let g:AutoPairsMapCh = 0
let g:AutoPairs= {'(':')', '[':']', '{':'}',"'":"'",'"':'"'}


" vim-surround
" tutorials: <https://github.com/tpope/vim-surround>


" comment line
"  scrooloose/nerdcommenter
let g:NERDCreateDefaultMappings = 0
let g:NERDCommentEmptyLines = 0
let g:NERDToggleCheckAllLines = 0
let g:NERDCustomDelimiters = {
\    'c': { 'left': '// ' }
\}
nmap <silent> gcc <Plug>NERDCommenterToggle
vmap <silent> gc  <Plug>NERDCommenterToggle


" navigate
"  easymotion/vim-easymotion
map \\ <Plug>(easymotion-prefix)
" <Leader>f{char} to move to {char}
map  <Leader>m <Plug>(easymotion-bd-f)
nmap <Leader>m <Plug>(easymotion-overwin-f)
" s{char}{char} to move to {char}{char}
nmap s         <Plug>(easymotion-overwin-f2)
" Move to line
map  <Leader>L <Plug>(easymotion-bd-jk)
nmap <Leader>L <Plug>(easymotion-overwin-line)
" Move to word
map  <Leader>w <Plug>(easymotion-bd-w)
nmap <Leader>w <Plug>(easymotion-overwin-w)


" undo Tree
let g:undotree_DiffAutoOpen = 0
let g:undotree_SetFocusWhenToggle = 1
nnoremap <silent> U <CMD>UndotreeToggle<CR>


" indentLine
let g:indent_guides_guide_size      = 1  " 指定对齐线的尺寸
let g:indent_guides_start_level     = 2  " 从第二层开始可视化显示缩进
let g:indentLine_fileTypeExclude = ['coc-explorer', 'which_key']

" Easy Align
let g:easy_align_bypass_fold = 1
"   Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
"   Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
