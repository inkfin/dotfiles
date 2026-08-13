-- ~/.config/nvim.mini/lua/lang/rime.lua
-- rime-ls: Chinese input inside Neovim via LSP completion, powered by blink.cmp.
--
-- rime-ls (https://github.com/wlh320/rime-ls) is a language server built on
-- librime. It speaks `textDocument/completion`, so blink.cmp renders its
-- candidates through the regular `lsp` source — no nvim-cmp-specific plugin is
-- needed. Two details make it behave like an IME instead of plain completion:
--
--   1. `long_filter_text = true` — blink.cmp filters candidates strictly, so
--      rime-ls must send the full pinyin as `filterText` or items get dropped.
--   2. Candidate order rides in `sortText` ("z001", "z002", …); blink.cmp's
--      default `fuzzy.sorts = { 'score', 'sort_text' }` already honours it once
--      fuzzy scores tie (every rime item shares one filterText).
--
-- Reference: https://github.com/wlh320/rime-ls/blob/master/doc/nvim-with-blink.md
--
-- Profile isolation — rime is gated by two independent switches:
--   machine level: `lang.rime = true` in lua/local.lua (binary + dict installed)
--   session level: the `nvim-rime` wrapper exports `NVIM_RIME=1`, so plain
--                  `nvim` never starts rime while `nvim-rime` does.
-- Within a rime session, <leader>rt toggles it per buffer.

local lsp = require("lsp_util")

local M = {}

local RIME_FILETYPES = { "markdown", "quarto", "org", "norg", "text" }

local function exe()
    return vim.fn.getenv("HOME") .. "/.local/bin/rime_ls"
        .. (vim.fn.has("win32") == 1 and ".exe" or "")
end

local function user_data_dir()
    return vim.fn.getenv("HOME") .. "/.local/share/rime-ls"
end

local function shared_data_dir()
    if vim.fn.has("mac") == 1 then
        return "/Library/Input Methods/Squirrel.app/Contents/SharedSupport"
    elseif vim.fn.has("win32") == 1 then
        return "C:\\Program Files (x86)\\Rime\\weasel-0.16.1\\data"
    end
    return "/usr/share/rime-data"
end

--- True when the rime_ls binary is installed (via chezmoi external.rime).
function M.available()
    return vim.fn.filereadable(exe()) == 1
end

--- True when this session is a rime session: binary present and the `nvim-rime`
--- entry point (NVIM_RIME=1) was used. Plain `nvim` keeps rime off.
function M.enabled()
    return M.available() and vim.env.NVIM_RIME == "1"
end

function M.setup()
    if not M.enabled() then return end

    lsp.setup("rime_ls", {
        cmd = { exe() },
        filetypes = RIME_FILETYPES,
        init_options = {
            enabled = true,
            shared_data_dir = shared_data_dir(),
            user_data_dir = user_data_dir(),
            log_dir = user_data_dir() .. "/log",
            max_candidates = 9,
            trigger_characters = {},
            schema_trigger_character = "&",
            long_filter_text = true, -- required: blink.cmp filters candidates strictly
            preselect_first = false,
        },
    })
    lsp.enable("rime_ls")

    local augroup = vim.api.nvim_create_augroup("nvim_mini_rime", { clear = true })

    -- rime is on by default in a rime session; <leader>rt flips it per buffer.
    vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = RIME_FILETYPES,
        callback = function()
            vim.b.rime_enabled = true
        end,
    })

    vim.keymap.set("n", "<leader>rt", function()
        vim.b.rime_enabled = not vim.b.rime_enabled
        vim.notify("Rime " .. (vim.b.rime_enabled and "on" or "off"))
    end, { silent = true, desc = "Toggle rime (Chinese input)" })

    vim.keymap.set("n", "<leader>rs", M.sync, { silent = true, desc = "Sync rime user data" })
end

--- Ask rime-ls to flush/sync its user dictionary.
function M.sync()
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0, name = "rime_ls" })) do
        client:request("workspace/executeCommand", { command = "rime-ls.sync_user_data" })
    end
end

--- IME-style blink.cmp keymaps. Merged into blink.setup() by plugins/blink.lua.
--- Each mapping falls through to normal typing unless rime is active AND the
--- menu holds an n-th rime candidate.
function M.blink_keymaps()
    if not M.enabled() then return {} end

    -- Index of the n-th rime candidate in the current menu, or nil.
    local function nth_rime_index(n)
        local items = require("blink.cmp.completion.list").items
        if items == nil then return nil end
        local seen = 0
        for i, item in ipairs(items) do
            if item.client_name == "rime_ls" then
                seen = seen + 1
                if seen == n then return i end
            end
        end
    end

    local function select_nth(cmp, n)
        if not vim.b.rime_enabled then return false end
        local idx = nth_rime_index(n)
        if idx == nil then return false end
        return cmp.accept({ index = idx })
    end

    local keys = {}
    for i = 1, 9 do
        keys[tostring(i)] = { function(cmp) return select_nth(cmp, i) end, "fallback" }
    end
    -- Space confirms the first candidate (the default IME behaviour).
    keys["<Space>"] = { function(cmp) return select_nth(cmp, 1) end, "fallback" }
    return keys
end

return M
