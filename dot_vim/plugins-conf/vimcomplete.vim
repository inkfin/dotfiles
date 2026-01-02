" vimcomplete.vim

if g:diag_backend !=# "vimcomplete"
    finish
endif
vim9script

# behavior
g:vimcomplete_tab_enable = 1
g:vimcomplete_cr_enable = 1

var options = {
    completor: {
        shuffleEqualPriority: true,
        noNewlineInCompletionEver: true,
    },
    buffer: { enable: true, priority: 10, urlComplete: true, envComplete: true },
    abbrev: { enable: true, priority: 10 },
    lsp: { enable: true, priority: 10, maxCount: 5 },
    tag: { enable: true, priority: 9, maxCount: 5 },
    omnifunc: { enable: false, priority: 8, filetypes: ['python', 'javascript'] },
    vsnip: { enable: false, priority: 9 },
    vimscript: { enable: true, priority: 11 },
    ngram: {
        enable: true,
        priority: 10,
        bigram: false,
        filetypes: ['text', 'help', 'markdown'],
        filetypesComments: ['c', 'cpp', 'python'],
    },
}
autocmd VimEnter * g:VimCompleteOptionsSet(options)

# complete info
var infowindow_options = {
    drag: false,
    close: 'none',
    resize: false,
}
autocmd VimEnter * g:VimCompleteInfoWindowOptionsSet(infowindow_options)
#nmap <silent> <C-u> <Plug>(vimcomplete-info-window-pageup)
#nmap <silent> <C-d> <Plug>(vimcomplete-info-window-pagedown)

