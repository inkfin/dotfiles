-- ~/.config/nvim.mini/lua/plugins/lualine.lua
-- Statusline based on LazyVim's defaults, trimmed to the pieces this config
-- already uses. The two user-visible additions are:
--   1. `selectioncount` in visual mode.
--   2. current code context via `nvim-navic`.

require("pack").add("https://github.com/nvim-lualine/lualine.nvim")

local ok, lualine = pcall(require, "lualine")
if not ok then return end

local ok_noice, noice = pcall(require, "noice")
local ok_dap, dap = pcall(require, "dap")
local ok_navic, navic = pcall(require, "nvim-navic")

-- `dap.status()` is cheap enough to query on redraw and mirrors LazyVim's
-- statusline behaviour. Keeping it as a tiny helper makes the section table
-- easier to scan than embedding the string formatting inline.
local function dap_status()
    return "  " .. dap.status()
end

-- Lualine does not ship a built-in `navic` component in this installation, so
-- expose navic as a plain function component instead. Returning an empty string
-- makes lualine skip visible output when no LSP symbol context is available.
local function navic_location()
    if not ok_navic then return "" end

    -- `is_available()` is false for buffers without an attached symbol-capable
    -- LSP client, so we avoid calling `get_location()` in unsupported buffers.
    local ok_available, available = pcall(navic.is_available)
    if not ok_available or not available then return "" end

    local ok_location, location = pcall(navic.get_location)
    return ok_location and location or ""
end

lualine.setup({
    options = {
        theme = "auto",
        globalstatus = vim.o.laststatus == 3,
        -- The defaults refresh very eagerly. A slightly slower refresh rate
        -- reduces statusline churn without making interactive updates feel laggy.
        refresh = {
            statusline = 200,
            tabline = 500,
            winbar = 500,
        },
        disabled_filetypes = {
            statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" },
        },
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
            -- Diagnostics first so error state stays visible even when the file
            -- path or breadcrumb needs to truncate on narrow windows.
            {
                "diagnostics",
                symbols = {
                    error = "󰅚 ",
                    warn  = "󰀦 ",
                    info  = "󰋽 ",
                    hint  = "󰌶 ",
                },
            },
            -- Keep the filetype icon, but not the text label; the filename and
            -- breadcrumb already identify the current buffer well enough.
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            -- `path = 1` shows the path relative to the current working
            -- directory, which is the closest built-in match to LazyVim's
            -- compact "pretty path" behaviour without pulling in its helpers.
            { "filename", path = 1 },
            -- Function / class / scope breadcrumb from `nvim-navic`.
            navic_location,
        },
        lualine_x = {
            {
                -- Noice command state, for example while typing `:` commands.
                function() return noice.api.status.command.get() end,
                cond = function()
                    return ok_noice and noice.api.status.command.has()
                end,
            },
            {
                -- Noice mode state, such as search or substitute prompts.
                function() return noice.api.status.mode.get() end,
                cond = function()
                    return ok_noice and noice.api.status.mode.has()
                end,
            },
            {
                -- Debug adapter status only while an active DAP session exists.
                dap_status,
                cond = function()
                    return ok_dap and dap.status() ~= ""
                end,
            },
            {
                "diff",
                source = function()
                    -- This config uses `mini.diff`, not gitsigns. If another
                    -- provider populates `vim.b.gitsigns_status_dict`, lualine
                    -- will still render counts. Otherwise this section stays
                    -- empty without breaking the rest of the statusline.
                    local gitsigns = vim.b.gitsigns_status_dict
                    if gitsigns then
                        return {
                            added = gitsigns.added,
                            modified = gitsigns.changed,
                            removed = gitsigns.removed,
                        }
                    end
                end,
            },
        },
        lualine_y = {
            -- Built-in lualine component: shows selected chars / lines / block
            -- size only while visual selection exists.
            "selectioncount",
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {
            -- Simple clock, matching the previous statusline behaviour.
            function()
                return " " .. os.date("%R")
            end,
        },
    },
    extensions = { "lazy", "fzf" },
})
