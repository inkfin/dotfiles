" fzf

if !PluginDisabled("fzf")

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

endif

