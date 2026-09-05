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
-- Completion mechanics (why each piece exists):
--
--   1. Space commits candidate #1 ONLY mid-composition (ASCII letter right
--      before the cursor). Everywhere else it falls through and inserts a
--      literal space — after a commit, between English words, after
--      punctuation. Digits 1-9 only need the menu to be open.
--   2. Candidate order rides in `sortText` ("z001", "z002", …); blink.cmp's
--      default `fuzzy.sorts = { 'score', 'sort_text' }` already honours it
--      once fuzzy scores tie (every rime item shares one filterText).
--   3. rime-ls' input regex treats ASCII punctuation as pinyin input, so
--      typing "+" pops a menu of full-width candidates. The lsp provider's
--      `transform_items` drops rime items when the trailing input chunk
--      contains no letters, and — while rime candidates ARE shown — hides
--      every other source so the menu stays a clean candidate bar.
--
-- Profile isolation — rime is gated by ONE hard switch, `lang.rime` in
-- lua/local.lua (default OFF). This file stays a plain lua module on
-- purpose: no chezmoi templating, so the config loads anywhere.
--
--   * switch OFF (default): rime never activates, zero cost.
--   * switch ON, rime-ls installed: the LSP server registers immediately
--     but attaches lazily — vim.lsp.enable only spawns rime_ls when a
--     buffer with one of RIME_FILETYPES opens, so non-markdown editing
--     pays nothing. Those buffers start with rime ON (<leader>rt toggles).
--   * switch ON, rime-ls MISSING: a one-shot warning explains how to
--     install it (chezmoi `[data.external] rime`) instead of failing
--     silently or spawning a dead server.
--
-- Installed here means both pieces that .chezmoiexternals/rime.toml ships:
-- the rime_ls binary and the frost user dicts (~/.local/share/rime-ls).

-- `lsp_util` owns server registration (`setup`) and `vim.lsp.enable`
-- wrapping, same as every other module under lua/lang/.
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

--- True when rime-ls is fully installed: both the rime_ls binary and the
--- frost user dicts that .chezmoiexternals/rime.toml ships. A leftover
--- binary without dicts cannot initialize librime.
function M.available()
    return vim.fn.filereadable(exe()) == 1
        and vim.fn.isdirectory(user_data_dir()) == 1
end

--- True when the local.lua hard switch is on AND rime-ls is installed.
function M.enabled()
    local ok_local, local_cfg = pcall(require, "local")
    return ok_local and local_cfg.lang.rime == true and M.available()
end

function M.setup()
    if M.available() then
        return M._enable()
    end

    -- Switch is on but rime-ls is missing: point at the install path once
    -- (scheduled so the message survives the startup UI handoff).
    vim.schedule(function()
        vim.notify(
            "rime: lang.rime=true but rime-ls is not installed.\n"
                .. "Install: set  [data.external] rime = true  in ~/.config/chezmoi/chezmoi.toml\n"
                .. "then run  chezmoi apply  (downloads the rime_ls binary + rime-frost dicts).",
            vim.log.levels.WARN,
            { title = "nvim.mini / rime" }
        )
    end)
end

function M._enable()
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
            -- "=" pages candidates (rime_ice binds = to next page mid-
            -- composition); after a commit it falls through rime's punct
            -- handler and types a literal "=". "-" and "," are too common
            -- in prose to hijack.
            paging_characters = { "=" },
            schema_trigger_character = "&",
            long_filter_text = true, -- required: blink.cmp filters candidates strictly
            preselect_first = false,
        },
    })
    lsp.enable("rime_ls")

    local augroup = vim.api.nvim_create_augroup("nvim_mini_rime", { clear = true })

    -- rime is on by default in markdown-ish buffers; <leader>rt flips it
    -- per buffer. Non-matching filetypes never get the flag (and never
    -- spawn rime_ls, see the `filetypes` gate on the server config).
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

    -- The menu window is the source of truth for visibility; list.items is
    -- cleared on hide, but checking the window keeps us honest about stale
    -- scheduled refreshes.
    local function menu_open()
        local ok, menu = pcall(require, "blink.cmp.completion.windows.menu")
        return ok and menu.win ~= nil and menu.win:is_open()
    end

    -- True while pinyin composition is live: an ASCII letter right before
    -- the cursor (mirrors the tail of rime-ls' input regex, which is
    -- [a-zA-Z[:punct:]]+). After a commit, between English words, or after
    -- punctuation there is no letter directly before the cursor.
    local function composing()
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2] -- 0-based byte offset
        return line:sub(1, col):match("[a-zA-Z]$") ~= nil
    end

    local function select_nth(cmp, n)
        if not vim.b.rime_enabled then return false end
        if not menu_open() then return false end
        -- Space doubles as a text character: only commit the first candidate
        -- mid-composition, otherwise insert a literal space. Digits have no
        -- plain-text meaning while the menu is open, so they always select.
        if n == 1 and not composing() then return false end
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

--- blink.cmp source tuning for rime. Merged into blink.setup() by
--- plugins/blink.lua. The lsp provider transform serves two purposes:
---
---   * 混排污染: while rime candidates are present the menu IS the IME
---     candidate bar, so marksman/buffer/path items only add noise.
---   * 标点误触发: rime-ls' input regex accepts ASCII punctuation, so typing
---     "+" (or ",", "///" after a commit) pops a menu of full-width symbol
---     candidates. Drop rime items when the trailing input chunk contains
---     no ASCII letters — pinyin composition always has letters.
function M.blink_sources()
    if not M.enabled() then return {} end

    -- rime-ls input chunk equivalent: trailing run of letters + ASCII
    -- punctuation right before the cursor.
    local function trailing_chunk(line, col)
        return line:sub(1, col):match("[a-zA-Z%p]+$") or ""
    end

    return {
        providers = {
            lsp = {
                transform_items = function(ctx, items)
                    if not vim.b[ctx.bufnr].rime_enabled then return items end
                    local rime_items, others = {}, {}
                    for _, item in ipairs(items) do
                        if item.client_name == "rime_ls" then
                            table.insert(rime_items, item)
                        else
                            table.insert(others, item)
                        end
                    end
                    if #rime_items == 0 then return items end
                    local chunk = trailing_chunk(ctx.line, ctx.cursor[2])
                    if chunk:match("[a-zA-Z]") == nil then return others end
                    return rime_items
                end,
            },
        },
    }
end

return M
