" highlighter
Plug 'rrethy/vim-illuminate'


" undo Tree
Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }

let g:undotree_DiffAutoOpen = 0
let g:undotree_SetFocusWhenToggle = 1
nnoremap <silent> U <CMD>UndotreeToggle<CR>


" indentLine
Plug 'Yggdroot/indentLine'

let g:indent_guides_guide_size      = 1  " 指定对齐线的尺寸
let g:indent_guides_start_level     = 2  " 从第二层开始可视化显示缩进
let g:indentLine_fileTypeExclude = ['coc-explorer', 'which_key']

