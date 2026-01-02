if g:diag_backend !=# "lsp"
    finish
endif
vim9script

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
