-- ~/.config/nvim.mini/lua/plugins/mini.lua
-- Configure mini.nvim modules
-- (mini.nvim is a single repo containing many small, independent plugins)

require("pack").add("https://github.com/echasnovski/mini.nvim")

-- Guard: on first launch vim.pack downloads asynchronously; skip if not ready yet.
if not pcall(require, "mini.surround") then return end

-- mini.surround ─────────────────────────────────────────────────────────────
require("mini.surround").setup({
    mappings = {
        add            = "gsa",
        delete         = "gsd",
        find           = "gsf",
        find_left      = "gsF",
        highlight      = "gsh",
        replace        = "gsr",
        update_n_lines = "gsn",
    },
})

-- mini.comment ──────────────────────────────────────────────────────────────
require("mini.comment").setup({
    options = { ignore_blank_line = true },
    mappings = {
        comment        = "gc",
        comment_line   = "gcc",
        comment_visual = "gc",
        textobject     = "gc",
    },
})

-- mini.ai ───────────────────────────────────────────────────────────────────
require("mini.ai").setup({ n_lines = 500 })

-- mini.pairs ────────────────────────────────────────────────────────────────
require("mini.pairs").setup()

-- mini.icons ────────────────────────────────────────────────────────────────
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()


-- mini.align ────────────────────────────────────────────────────────────────
-- ga  — start align (interactive: pick delimiter, then modifiers)
-- gA  — start align with preview
require("mini.align").setup({
    mappings = {
        start         = "ga",
        start_with_preview = "gA",
    },
})

-- mini.cursorword ───────────────────────────────────────────────────────────
-- Automatically highlight all occurrences of the word under the cursor.
require("mini.cursorword").setup()
