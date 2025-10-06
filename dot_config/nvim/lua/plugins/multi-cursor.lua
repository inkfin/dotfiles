return {
    {
        "jake-stewart/multicursor.nvim",
        branch = "1.0",
        config = function()
            local mc = require("multicursor-nvim")
            mc.setup()

            local set = vim.keymap.set

            -- Add or skip cursor above/below the main cursor.
            set({ "n", "x" }, "<M-up>", function()
                mc.lineAddCursor(-1)
            end)
            set({ "n", "x" }, "<M-down>", function()
                mc.lineAddCursor(1)
            end)
            set({ "n", "x" }, "<up>", function()
                mc.lineSkipCursor(-1)
            end)
            set({ "n", "x" }, "<down>", function()
                mc.lineSkipCursor(1)
            end)

            -- Add or skip adding a new cursor by matching word/selection
            set({ "n", "x" }, "gb", function()
                mc.matchAddCursor(1)
            end)
            set({ "n", "x" }, "<Leader>as", function()
                mc.matchSkipCursor(1)
            end)
            set({ "n", "x" }, "gB", function()
                mc.matchAddCursor(-1)
            end)
            set({ "n", "x" }, "<Leader>aS", function()
                mc.matchSkipCursor(-1)
            end)

            -- Add and remove cursors with control + left click.
            set("n", "<M-leftmouse>", mc.handleMouse)
            set("n", "<M-leftdrag>", mc.handleMouseDrag)
            set("n", "<M-leftrelease>", mc.handleMouseRelease)

            -- Disable and enable cursors.
            set({ "n", "x" }, "<leader>ac", mc.toggleCursor)

            -- Mappings defined in a keymap layer only apply when there are
            -- multiple cursors. This lets you have overlapping mappings.
            mc.addKeymapLayer(function(layerSet)
                -- Select a different cursor as the main one.
                layerSet({ "n", "x" }, "<left>", mc.prevCursor)
                layerSet({ "n", "x" }, "<right>", mc.nextCursor)

                -- Delete the main cursor.
                layerSet({ "n", "x" }, "<leader>ad", mc.deleteCursor)

                -- Enable and clear cursors using escape.
                layerSet("n", "<esc>", function()
                    if not mc.cursorsEnabled() then
                        mc.enableCursors()
                    else
                        mc.clearCursors()
                    end
                end)
            end)

            -- Customize how cursors look.
            local hl = vim.api.nvim_set_hl
            hl(0, "MultiCursorCursor", { reverse = true })
            hl(0, "MultiCursorVisual", { link = "Visual" })
            hl(0, "MultiCursorSign", { link = "SignColumn" })
            hl(0, "MultiCursorMatchPreview", { link = "Search" })
            hl(0, "MultiCursorDisabledCursor", { reverse = true })
            hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
            hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
        end,
    },
    -- {
    --     "mg979/vim-visual-multi",
    --     branch = "master",
    --     init = function()
    --         -- https://github.com/mg979/vim-visual-multi/wiki/Mappings

    --         vim.cmd([[
    --             let g:VM_default_mappings = 0

    --             let g:VM_mouse_mappings = 0
    --             " | Key            | Action                            |
    --             " | -------------- | --------------------------------- |
    --             " | C-LeftMouse    | add cursor at clicked position    |
    --             " | C-RightMouse   | select clicked word               |
    --             " | M-C-RightMouse | create column of cursors          |

    --             let g:VM_maps = {}
    --             let g:VM_maps["Add Cursor At Pos"]  = '<C-,>'         " after adding cursor, use arrow key to navigate
    --             let g:VM_maps["Add Cursor Down"]    = '<M-Down>'      " start selecting down
    --             let g:VM_maps["Add Cursor Up"]      = '<M-Up>'        " start selecting up
    --             let g:VM_maps['Find Under']         = ''              " disable find under

    --             let g:VM_maps["Mouse Word"]         = '<C-RightMouse>'
    --             let g:VM_maps["Mouse Cursor"]       = '<M-LeftMouse>'

    --             " other basic mappings
    --             let g:VM_maps["Find Next"]          = ']'
    --             let g:VM_maps["Find Prev"]          = '['
    --             let g:VM_maps["Goto Next"]          = '}'
    --             let g:VM_maps["Goto Prev"]          = '{'
    --             let g:VM_maps["Seek Next"]          = '<C-f>'
    --             let g:VM_maps["Seek Prev"]          = '<C-b>'
    --             let g:VM_maps["Skip Region"]        = 'q'
    --             let g:VM_maps["Remove Region"]      = 'Q'
    --             let g:VM_maps["Invert Direction"]   = 'o'
    --             let g:VM_maps["Find Operator"]      = "m"
    --             let g:VM_maps["Surround"]           = 'S'
    --             let g:VM_maps["Replace Pattern"]    = 'R'
    --         ]])
    --     end,
    -- },
}
