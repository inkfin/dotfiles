return {
    {
        "iamcco/markdown-preview.nvim",
        ft = "markdown",
        lazy = true,
        config = function()
            vim.cmd([[
                " options for markdown render
                " mkit: markdown-it options for render
                " katex: katex options for math
                " uml: markdown-it-plantuml options
                " maid: mermaid options
                " disable_sync_scroll: if disable sync scroll, default 0
                " sync_scroll_type: 'middle', 'top' or 'relative', default value is 'middle'
                "   middle: mean the cursor position alway show at the middle of the preview page
                "   top: mean the vim top viewport alway show at the top of the preview page
                "   relative: mean the cursor position alway show at the relative positon of the preview page
                " hide_yaml_meta: if hide yaml metadata, default is 1
                " sequence_diagrams: js-sequence-diagrams options
                " content_editable: if enable content editable for preview page, default: v:false
                " disable_filename: if disable filename header for preview page, default: 0
                let g:mkdp_preview_options = {
                    \ 'mkit': {},
                    \ 'katex': {},
                    \ 'uml': {},
                    \ 'maid': {},
                    \ 'disable_sync_scroll': 0,
                    \ 'sync_scroll_type': 'middle',
                    \ 'hide_yaml_meta': 0,
                    \ 'sequence_diagrams': {},
                    \ 'flowchart_diagrams': {},
                    \ 'content_editable': v:false,
                    \ 'disable_filename': 1,
                    \ 'toc': {}
                    \ }
            ]])
        end,
    },
}
