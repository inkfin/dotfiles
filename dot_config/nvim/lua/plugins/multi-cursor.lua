return {
    {
        "mg979/vim-visual-multi",
        branch = "master",
        init = function()
            -- https://github.com/mg979/vim-visual-multi/wiki/Mappings

            vim.cmd([[
                let g:VM_default_mappings = 0

                let g:VM_mouse_mappings = 0
                " | Key            | Action                            |
                " | -------------- | --------------------------------- |
                " | C-LeftMouse    | add cursor at clicked position    |
                " | C-RightMouse   | select clicked word               |
                " | M-C-RightMouse | create column of cursors          |

                let g:VM_maps = {}
                let g:VM_maps["Add Cursor At Pos"]  = '<C-]>'         " after adding cursor, use arrow key to navigate
                let g:VM_maps["Add Cursor Down"]    = '<M-Down>'      " start selecting down
                let g:VM_maps["Add Cursor Up"]      = '<M-Up>'        " start selecting up

                let g:VM_maps["Mouse Word"]         = '<C-RightMouse>'
                let g:VM_maps["Mouse Cursor"]       = '<M-LeftMouse>'

                " other basic mappings
                let g:VM_maps["Find Next"]          = ']'
                let g:VM_maps["Find Prev"]          = '['
                let g:VM_maps["Goto Next"]          = '}'
                let g:VM_maps["Goto Prev"]          = '{'
                let g:VM_maps["Seek Next"]          = '<C-f>'
                let g:VM_maps["Seek Prev"]          = '<C-b>'
                let g:VM_maps["Skip Region"]        = 'q'
                let g:VM_maps["Remove Region"]      = 'Q'
                let g:VM_maps["Invert Direction"]   = 'o'
                let g:VM_maps["Find Operator"]      = "m"
                let g:VM_maps["Surround"]           = 'S'
                let g:VM_maps["Replace Pattern"]    = 'R'
            ]])
        end,
    },
}
