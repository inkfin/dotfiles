if !has("vim9script") || v:version < 900 || !g:enable_lsp
    finish
endif
vim9script

Plug 'yegappan/lsp'

var lspOpts = {
    autoHighlightDiags: true,
}
autocmd User LspSetup g:LspOptionsSet(lspOpts)

var lspServers = [
    {
        name: 'clangd',
        filetype: ['c', 'cpp'],
        path: 'clangd',
        args: ['--background-index']
    },
    {
        name: 'vimls',
        filetype: ['vim'],
        path: 'bun',
        args: ['run', '-b', '~/.vim/lsp/node_modules/vim-language-server', '--stdio']
    },
]
autocmd User LspSetup g:LspAddServer(lspServers)

nmap <silent> <leader>ch <CMD>LspSwitchSourceHeader<CR>
#..todo
