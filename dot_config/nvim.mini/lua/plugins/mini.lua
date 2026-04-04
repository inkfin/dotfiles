-- ~/.config/nvim.mini/lua/plugins/mini.lua
-- Configure mini.nvim modules
-- (mini.nvim is a single repo containing many small, independent plugins)

require("pack").add("https://github.com/echasnovski/mini.nvim")

-- Guard: on first launch vim.pack downloads asynchronously; skip if not ready yet.
if not pcall(require, "mini.surround") then return end

local ok_local, local_cfg = pcall(require, "local")
local_cfg = ok_local and local_cfg or {}

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

-- mini.diff ─────────────────────────────────────────────────────────────────
-- In-buffer git diff signs (replaces gitsigns for hunk display).
-- gh  — toggle hunk overlay (shows full old/new in a float)
require("mini.diff").setup({
    view = {
        style = "sign",
        signs = { add = "▎", change = "▎", delete = "" },
    },
    mappings = {
        -- Hunk navigation
        goto_first = "[H",
        goto_prev  = "[h",
        goto_next  = "]h",
        goto_last  = "]H",
        -- Apply/reset hunks (operator — works with motion or visual)
        apply = "gh",
        reset = "gH",
    },
})

-- mini.clues ────────────────────────────────────────────────────────────────
-- Which-key style popup showing available keymap completions.
if local_cfg.mini_clue ~= false then
local clues = require("mini.clue")
clues.setup({
    triggers = {
        -- Normal mode leaders
        { mode = "n", keys = "<leader>" },
        { mode = "n", keys = "g" },
        { mode = "n", keys = "[" },
        { mode = "n", keys = "]" },
        { mode = "n", keys = "z" },
        { mode = "n", keys = '"' },
        { mode = "n", keys = "'" },
        { mode = "n", keys = "`" },
        -- Visual mode
        { mode = "x", keys = "<leader>" },
        { mode = "x", keys = "g" },
        -- Insert / operator
        { mode = "i", keys = "<C-x>" },
        { mode = "o", keys = "a" },
        { mode = "o", keys = "i" },
    },
    clues = {
        -- Built-in clue groups
        clues.gen_clues.builtin_completion(),
        clues.gen_clues.g(),
        clues.gen_clues.marks(),
        clues.gen_clues.registers(),
        clues.gen_clues.windows(),
        clues.gen_clues.z(),
        -- Describe <leader> sub-groups
        { mode = "n", keys = "<leader>b",  desc = "+buffer" },
        { mode = "n", keys = "<leader>c",  desc = "+code" },
        { mode = "n", keys = "<leader>f",  desc = "+find" },
        { mode = "n", keys = "<leader>g",  desc = "+git" },
        { mode = "n", keys = "<leader>p",  desc = "+pack" },
        { mode = "n", keys = "<leader>r",  desc = "+refactor" },
        { mode = "n", keys = "<leader>s",  desc = "+search" },
        { mode = "n", keys = "<leader>t",  desc = "+tab" },
        { mode = "n", keys = "<leader>u",  desc = "+ui" },
        { mode = "n", keys = "<leader>y",  desc = "+yazi" },
    },
    window = {
        delay     = 300,
        config    = { border = "rounded" },
        scroll_down = "<C-d>",
        scroll_up   = "<C-u>",
    },
})
end -- mini_clue

-- mini.statusline ───────────────────────────────────────────────────────────
require("mini.statusline").setup({ use_icons = true })
