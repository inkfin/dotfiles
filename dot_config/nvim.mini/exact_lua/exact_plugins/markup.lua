-- ~/.config/nvim.mini/lua/plugins/markup.lua
-- Markup rendering enhancements and markdown-centric writing UX.
--
-- This keeps the markup feature set intentionally small in nvim.mini:
-- - `render-markdown.nvim` for in-editor Obsidian-like visual rendering.
--   This also covers the old headlines.nvim role: the heading config below
--   gives every heading level a full-width background bar (the successor
--   route recommended by headlines' author and by LazyVim upstream, since
--   headlines.nvim is effectively unmaintained and broken on Neovim 0.12).
-- - a Snacks toggle on `<leader>um` to turn rendering on/off per session.
-- - `<localleader>t*` task toggles so markdown checkboxes can be edited by
--   mnemonic status names instead of remembering symbolic forms like `[!]`.
-- - inline image rendering via snacks.image (kitty graphics protocol, which
--   ghostty supports and snacks passes through tmux). Markdown buffers start
--   with images OFF; `<localleader>mi` toggles them per buffer.
--
-- LSP support itself lives in `lang/markdown.lua` so the server install and
-- enablement follow the same registry path as the other language configs.

require("pack").add({
    "https://github.com/MeanderingProgrammer/render-markdown.nvim",
})

local ok, render_markdown = pcall(require, "render-markdown")
if not ok then return end

-- Reuse the old Headline1..6 groups (linked to Headline -> ColorColumn) so
-- the heading bars keep the same subdued background tone headlines.nvim had,
-- instead of the brighter per-level colors render-markdown defaults to.
for i = 1, 6 do
    vim.api.nvim_set_hl(0, "Headline" .. i, { link = "Headline", default = true })
end

render_markdown.setup({
    file_types = { "markdown" },
    -- Keep the visual language close to the old LazyVim setup while still
    -- fitting this config's simpler plugin model.
    code = {
        sign = true,
        width = "block",
        border = "thick",
        left_pad = 0,
        right_pad = 4,
        min_width = 45,
    },
    heading = {
        sign = true,
        -- Full-width background bars on every heading level: this replaces
        -- headlines.nvim's headline_highlights + fat headlines look.
        backgrounds = {
            "Headline1", "Headline2", "Headline3",
            "Headline4", "Headline5", "Headline6",
        },
        widths = { "full", "full", "full", "full", "full", "full" },
    },
    pipe_table = {
        style = "normal",
    },
    latex = {
        enabled = false,
    },
    checkbox = {
        custom = {
            important   = { raw = "[!]", rendered = "󰀨 ", highlight = "DiagnosticWarn" },
            in_progress = { raw = "[/]", rendered = "󰓛 ", highlight = "DiagnosticInfo" },
            cancelled   = {
                raw = "[-]",
                rendered = "󰜺 ",
                highlight = "Comment",
                scope_highlight = "@markup.strikethrough",
            },
            deferred    = { raw = "[>]", rendered = "󰒊 ", highlight = "DiagnosticHint" },
            recurring   = { raw = "[+]", rendered = "󰑖 ", highlight = "DiagnosticInfo" },
            question    = { raw = "[?]", rendered = "󰋗 ", highlight = "DiagnosticHint" },
        },
    },
})

if Snacks and Snacks.toggle then
    Snacks.toggle({
        name = "Render Markdown",
        get = render_markdown.get,
        set = render_markdown.set,
    }):map("<leader>um")
end

-- ─── Inline image rendering (snacks.image) ───────────────────────────────────
--
-- snacks.image renders markdown images inline through the kitty graphics
-- protocol. Detection is automatic: ghostty answers the protocol query
-- directly; inside tmux snacks wraps every escape sequence in passthrough
-- (`.tmux.conf` has `allow-passthrough on`) and even sets pane-local
-- `allow-passthrough` itself. ImageMagick (`magick`) is required at runtime
-- to convert non-PNG formats (jpg, svg, pdf, ...).
--
-- Markdown buffers start with rendering OFF. snacks has no public toggle
-- (folke/snacks.nvim#1739), so we drive it with buffer-local state:
--   b:snacks_image_attached  snacks' own guard; set BEFORE its scheduled
--                            doc.attach runs to keep the default OFF
--   b:snacks_image_off       our ON/OFF state, checked by the toggle
--   b:snacks_image_epoch     bumped on every toggle; stamps each inline
--                            instance so stale ones go inert
--
-- The epoch stamp is what makes OFF durable: snacks keeps a per-buffer
-- `nvim_buf_attach` on_lines listener that no API can detach, and its
-- debounced update would re-create placements on every edit. We wrap
-- `inline.new` so each instance captures the epoch at creation and its
-- update() becomes a no-op once the epoch moves on.
--
-- The whole block follows the per-machine `M.image` switch in local.lua —
-- on machines without a kitty-protocol terminal it never loads.
local ok_local, local_cfg = pcall(require, "local")
if ok_local and local_cfg.image == true then
    local inline = require("snacks.image.inline")
    local inline_new = inline.new
    inline.new = function(buf)
        local self = inline_new(buf)
        local epoch = vim.b[buf].snacks_image_epoch or 0
        local update = self.update
        self.update = function(s, ...)
            if (vim.b[buf].snacks_image_epoch or 0) ~= epoch then return end
            return update(s, ...)
        end
        return self
    end

    local function images_enable(buf)
        vim.b[buf].snacks_image_off      = false
        vim.b[buf].snacks_image_epoch    = (vim.b[buf].snacks_image_epoch or 0) + 1
        -- doc._attach bails out on this flag, so clear it for the manual attach
        vim.b[buf].snacks_image_attached = false
        require("snacks.image.doc").attach(buf)
    end

    local function images_disable(buf)
        vim.b[buf].snacks_image_off   = true
        vim.b[buf].snacks_image_epoch = (vim.b[buf].snacks_image_epoch or 0) + 1
        -- close current placements (extmarks + terminal images) ...
        pcall(Snacks.image.placement.clean, buf)
        -- ... and stop float-hover mode from re-following the cursor on
        -- terminals without unicode placeholder support
        pcall(vim.api.nvim_clear_autocmds, { group = "snacks.image.doc." .. buf })
    end

    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("nvim_mini_markdown_images", { clear = true }),
        pattern = "markdown",
        callback = function(ev)
            local buf = ev.buf
            -- Default OFF. snacks registers its doc FileType autocmd on the
            -- first BufReadPre and defers the actual attach with vim.schedule,
            -- so setting the guard here (synchronously, during the FileType
            -- event) reliably pre-empts it.
            vim.b[buf].snacks_image_attached = true
            vim.b[buf].snacks_image_off      = true
            vim.b[buf].snacks_image_epoch    = 0

            vim.keymap.set("n", "<localleader>mi", function()
                if vim.b[buf].snacks_image_off then
                    images_enable(buf)
                else
                    images_disable(buf)
                end
            end, { buffer = buf, silent = true, desc = "Toggle inline images" })

            local ok_wk, wk = pcall(require, "which-key")
            if ok_wk then
                wk.add({ buffer = buf, { "<localleader>mi", desc = "Toggle inline images" } })
            end
        end,
    })
end

local markdown_task_states = {
    t = "[ ]",
    x = "[x]",
    i = "[/]",
    c = "[-]",
    d = "[>]",
    r = "[+]",
    q = "[?]",
    e = "[!]",
}

local markdown_heading_prefixes = {
    [1] = "# ",
    [2] = "## ",
    [3] = "### ",
    [4] = "#### ",
    [5] = "##### ",
    [6] = "###### ",
}

local function set_markdown_task_state(raw)
    return function()
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
        local updated, count = line:gsub("^([%s]*[-*+]%s+)%b[]", "%1" .. raw, 1)

        if count == 0 then
            vim.notify("Current line is not a markdown task item", vim.log.levels.WARN)
            return
        end

        vim.api.nvim_buf_set_lines(0, row, row + 1, false, { updated })
    end
end

local function set_markdown_heading(level)
    return function()
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
        local content = line:gsub("^%s*#+%s*", "")
        local updated = markdown_heading_prefixes[level] .. content
        vim.api.nvim_buf_set_lines(0, row, row + 1, false, { updated })
    end
end

local function cycle_markdown_heading(reverse)
    return function()
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
        local hashes, content = line:match("^(%s*#+)%s*(.*)$")
        local current = hashes and #hashes:gsub("%s", "") or 0
        local next_level

        if reverse then
            if current <= 1 then
                next_level = 6
            else
                next_level = current - 1
            end
        else
            if current == 0 or current >= 6 then
                next_level = 1
            else
                next_level = current + 1
            end
        end

        local updated = markdown_heading_prefixes[next_level] .. (content or line)
        vim.api.nvim_buf_set_lines(0, row, row + 1, false, { updated })
    end
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("nvim_mini_markdown_tasks", { clear = true }),
    pattern = { "markdown" },
    callback = function(ev)
        local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
        end

        map("<localleader>tt", set_markdown_task_state(markdown_task_states.t), "Task Unchecked")
        map("<localleader>tx", set_markdown_task_state(markdown_task_states.x), "Task Done")
        map("<localleader>ti", set_markdown_task_state(markdown_task_states.i), "Task In Progress")
        map("<localleader>tc", set_markdown_task_state(markdown_task_states.c), "Task Cancelled")
        map("<localleader>td", set_markdown_task_state(markdown_task_states.d), "Task Deferred")
        map("<localleader>tr", set_markdown_task_state(markdown_task_states.r), "Task Recurring")
        map("<localleader>tq", set_markdown_task_state(markdown_task_states.q), "Task Question")
        map("<localleader>te", set_markdown_task_state(markdown_task_states.e), "Task Important")

        map("<localleader>m1", set_markdown_heading(1), "Heading 1")
        map("<localleader>m2", set_markdown_heading(2), "Heading 2")
        map("<localleader>m3", set_markdown_heading(3), "Heading 3")
        map("<localleader>m4", set_markdown_heading(4), "Heading 4")
        map("<localleader>m5", set_markdown_heading(5), "Heading 5")
        map("<localleader>m6", set_markdown_heading(6), "Heading 6")
        map("<localleader>m>", cycle_markdown_heading(false), "Heading Cycle")
        map("<localleader>m<", cycle_markdown_heading(true), "Heading Cycle Reverse")

        local ok_wk, wk = pcall(require, "which-key")
        if ok_wk then
            wk.add({
                buffer = ev.buf,
                { "<localleader>t",  group = "markdown tasks" },
                { "<localleader>m",  group = "markdown headings" },
                { "<localleader>tt", desc = "Task Unchecked" },
                { "<localleader>tx", desc = "Task Done" },
                { "<localleader>ti", desc = "Task In Progress" },
                { "<localleader>tc", desc = "Task Cancelled" },
                { "<localleader>td", desc = "Task Deferred" },
                { "<localleader>tr", desc = "Task Recurring" },
                { "<localleader>tq", desc = "Task Question" },
                { "<localleader>te", desc = "Task Important" },
                { "<localleader>m1", desc = "Heading 1" },
                { "<localleader>m2", desc = "Heading 2" },
                { "<localleader>m3", desc = "Heading 3" },
                { "<localleader>m4", desc = "Heading 4" },
                { "<localleader>m5", desc = "Heading 5" },
                { "<localleader>m6", desc = "Heading 6" },
                { "<localleader>m>", desc = "Heading Cycle" },
                { "<localleader>m<", desc = "Heading Cycle Reverse" },
            })
        end
    end,
})
