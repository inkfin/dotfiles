-- ~/.config/nvim.mini/lua/lang/rime.lua
-- rime-ls: Chinese input inside Neovim via LSP completion, powered by blink.cmp.
--
-- Enabled by local.lua lang.rime; attaches only to prose filetypes.
-- Keep IME state per buffer. Filtering disabled candidates locally avoids
-- toggling a shared server out from under another buffer.
-- Space/numbers commit, Enter keeps raw input, [ and ] take the first/last character.
-- ;f / ;; enable/disable, ;j leaves Insert mode, ;u restores the last input.

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
    return ok_local and (local_cfg.lang or {}).rime == true and M.available()
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
            -- Same paging keys as cmp-lsp-rimels. Rime handles them only
            -- within a composition; ordinary punctuation stays literal.
            paging_characters = { ",", ".", "-", "=" },
            schema_trigger_character = "&",
            long_filter_text = true, -- required: blink.cmp filters candidates strictly
            preselect_first = false,
        },
    })

    local augroup = vim.api.nvim_create_augroup("nvim_mini_rime", { clear = true })

    -- rime is on by default in markdown-ish buffers; <leader>rt flips it
    -- per buffer. Non-matching filetypes never get the flag (and never
    -- spawn rime_ls, see the `filetypes` gate on the server config).
    vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = RIME_FILETYPES,
        callback = function(ev) M.attach(ev.buf) end,
    })

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.tbl_contains(RIME_FILETYPES, vim.bo[bufnr].filetype) then M.attach(bufnr) end
    end
    vim.keymap.set("n", "<leader>rt", function() M.toggle() end,
        { silent = true, desc = "Toggle rime (Chinese input)" })
    vim.keymap.set("n", "<leader>rs", M.sync, { silent = true, desc = "Sync rime user data" })
    vim.api.nvim_create_user_command("ToggleRime", function(opts)
        if opts.args == "" then M.toggle()
        elseif opts.args == "on" then M.toggle(true)
        elseif opts.args == "off" then M.toggle(false)
        else vim.notify("Usage: ToggleRime [on|off]", vim.log.levels.WARN) end
    end, { nargs = "?", complete = function() return { "on", "off" } end })
    vim.api.nvim_create_user_command("RimeSync", M.sync, {})
    -- Rime supplies punctuation according to the selected schema. Auto-commit
    -- only a single punctuation candidate after Chinese, never a stale reply.
    vim.api.nvim_create_autocmd("User", {
        group = augroup,
        pattern = "BlinkCmpShow",
        callback = function(ev)
            local ctx = ev.data and ev.data.context
            if not ctx or ctx.bufnr ~= vim.api.nvim_get_current_buf() or not M.active() then return end
            if ctx.line ~= vim.api.nvim_get_current_line()
                or ctx.cursor[2] ~= vim.api.nvim_win_get_cursor(0)[2] then return end
            local items = require("blink.cmp.completion.list").items or {}
            local input = ctx.line:sub(1, ctx.cursor[2])
            local selecting = input:match("[a-zA-Z&][a-zA-Z%p%d]*[1-9]$")
            if (selecting or M.punctuation_context(ctx.line, ctx.cursor[2])) and #items == 1
                and items[1].client_name == "rime_ls" then
                local item = items[1]
                local text = item.textEdit and item.textEdit.newText or item.insertText or item.label
                require("blink.cmp").accept({ index = 1, callback = M.remember(item, text) })
            end
        end,
    })
    lsp.enable("rime_ls")
end

--- Ask rime-ls to flush/sync its user dictionary.
function M.sync()
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0, name = "rime_ls" })) do
        client:request("workspace/executeCommand", { command = "rime-ls.sync-user-data" })
    end
end

-- Buffer-local mappings also work while the candidate menu is closed.
function M.attach(bufnr)
    if vim.b[bufnr].rime_enabled == nil then vim.b[bufnr].rime_enabled = true end
    local function map(lhs, rhs, desc, expr)
        vim.keymap.set("i", lhs, rhs, { buffer = bufnr, silent = true, desc = desc, expr = expr })
    end
    map(";f", function() M.toggle(true) end, "Enable Chinese input")
    map(";;", function() M.toggle(false) end, "Disable Chinese input")
    map(";j", "<Esc>", "Leave Insert mode")
    map(";u", M.undo, "Restore last Rime input", true)
end

function M.toggle(enabled)
    if not vim.tbl_contains(RIME_FILETYPES, vim.bo.filetype) then return end
    if enabled == nil then enabled = not vim.b.rime_enabled end
    vim.b.rime_enabled = enabled
    vim.b.rime_ascii = false
    local ok, cmp = pcall(require, "blink.cmp")
    if ok then cmp.cancel() end
    vim.notify("Rime " .. (enabled and "on" or "off"))
end

local function before_cursor()
    return vim.api.nvim_get_current_line():sub(1, vim.api.nvim_win_get_cursor(0)[2])
end

-- Restore only an unchanged commit immediately before the cursor. Do not
-- use normal-mode word deletion: it can eat neighbouring Chinese or Markdown.
function M.undo()
    local last = vim.b.rime_last_commit
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    if not last or last.row ~= row or before_cursor():sub(-#last.text) ~= last.text then return ";u" end
    local bufnr, tick = vim.api.nvim_get_current_buf(), vim.api.nvim_buf_get_changedtick(0)
    vim.schedule(function()
        if vim.api.nvim_get_current_buf() ~= bufnr or vim.api.nvim_buf_get_changedtick(bufnr) ~= tick then return end
        vim.api.nvim_buf_set_text(bufnr, row - 1, col - #last.text, row - 1, col, { last.input })
        vim.api.nvim_win_set_cursor(0, { row, col - #last.text + #last.input })
        vim.b.rime_last_commit = nil
    end)
    return ""
end

-- Match a punctuation key directly after a non-ASCII character. This keeps
-- Markdown operators, English punctuation and leading symbols literal.
function M.punctuation_context(line, col)
    local before = line:sub(1, col)
    if not vim.tbl_contains({ ",", ".", ":", "\\", "?", "!" }, before:sub(-1)) then return false end
    local previous = vim.fn.strcharpart(before, vim.fn.strchars(before) - 2, 1)
    return previous ~= "" and vim.fn.char2nr(previous) > 127
end

function M.active(bufnr)
    return vim.b[bufnr or 0].rime_enabled == true and not vim.b[bufnr or 0].rime_ascii
end

local function is_rime(item)
    return item and item.client_name == "rime_ls"
end

-- Capture the actual replacement range, not long_filter_text (which may
-- contain preceding Chinese). Save against the originating buffer on accept.
function M.remember(item, text)
    local bufnr = vim.api.nvim_get_current_buf()
    local input = item.filterText
    local range = item.textEdit and (item.textEdit.range or item.textEdit.insert)
    if range and range.start.line == range["end"].line then
        local line = vim.api.nvim_buf_get_lines(bufnr, range.start.line, range.start.line + 1, false)[1]
        local client = item.client_id and vim.lsp.get_client_by_id(item.client_id)
        local encoding = client and client.offset_encoding or "utf-16"
        local first = vim.str_byteindex(line, encoding, range.start.character, false)
        local last = vim.str_byteindex(line, encoding, range["end"].character, false)
        input = line:sub(first + 1, last)
    end
    local row = vim.api.nvim_win_get_cursor(0)[1]
    return function()
        if input and text ~= "" and vim.api.nvim_buf_is_valid(bufnr) then
            vim.b[bufnr].rime_last_commit = { input = input, text = text, row = row }
        end
    end
end

function M.blink_keymaps()
    if not M.enabled() then return {} end
    local function items(cmp)
        if not M.active() then return {} end
        local menu = require("blink.cmp.completion.windows.menu")
        if not menu.win or not menu.win:is_open() then return {} end
        return require("blink.cmp.completion.list").items or {}
    end
    local function nth(cmp, n)
        for i, item in ipairs(items(cmp)) do
            if is_rime(item) then
                n = n - 1
                if n == 0 then return i end
            end
        end
    end
    local function selected(cmp)
        local idx = cmp.get_selected_item_idx()
        if idx then return is_rime(items(cmp)[idx]) and idx or nil end
        return nth(cmp, 1)
    end
    local function commit(cmp, idx, edge)
        if not idx then return false end
        local list = require("blink.cmp.completion.list")
        local item = list.items[idx]
        local text = item.textEdit and item.textEdit.newText or item.insertText or item.label
        if edge then
            -- Work on a copy: cached candidates must retain their full text.
            item = vim.deepcopy(item)
            text = vim.fn.strcharpart(text, edge == "first" and 0 or vim.fn.strchars(text) - 1, 1)
            if item.textEdit then item.textEdit.newText = text else item.insertText = text end
            list.items[idx] = item
        end
        return cmp.accept({ index = idx, callback = M.remember(item, text) })
    end
    local keys = {}
    for n = 1, 9 do
        keys[tostring(n)] = { function(cmp)
            -- Send selection to Rime itself: this learns word choices and
            -- supports partial words and schema selection. BlinkCmpShow commits
            -- the resulting single candidate once the server has processed it.
            if nth(cmp, n) then return tostring(n) end
            return false
        end, "fallback" }
    end
    keys["<Space>"] = { function(cmp)
        local idx = selected(cmp)
        if idx then return commit(cmp, idx) end
        -- A space after Chinese opens a temporary English segment; after an
        -- ASCII word it returns to Chinese. Repeated/leading spaces do nothing.
        if vim.b.rime_enabled then
            local before = before_cursor()
            if before ~= "" and not before:match("%s$") then
                local after = vim.api.nvim_get_current_line():sub(#before + 1, #before + 1)
                if not (vim.b.rime_ascii and after:match("[!-~]")) then
                    vim.b.rime_ascii = not (before:match("[%w%p]$") ~= nil)
                end
            end
        end
        return false
    end, "fallback" }
    keys["<CR>"] = { function(cmp)
        if not selected(cmp) then return false end
        return cmp.cancel({ callback = function()
            vim.api.nvim_feedkeys(" ", "n", false)
        end })
    end, "accept", "fallback" }
    for key, edge in pairs({ ["["] = "first", ["]"] = "last" }) do
        keys[key] = { function(cmp) return commit(cmp, selected(cmp), edge) end, "fallback" }
    end
    keys["0"] = { function(cmp)
        if nth(cmp, 1) then cmp.cancel() end
        return false
    end, "fallback" }
    keys["<BS>"] = { function()
        if vim.b.rime_enabled and before_cursor():match("%S $") then
            vim.b.rime_ascii = before_cursor():sub(1, -2):match("[%w%p]$") ~= nil
        end
        return false
    end, "fallback" }
    return keys
end

function M.blink_sources()
    if not M.enabled() then return {} end
    return {
        -- Source transforms run separately for each provider. Restrict providers
        -- here, otherwise buffer/path/snippet results still pollute the IME menu.
        default = function()
            return M.active() and { "lsp" } or { "lsp", "path", "snippets", "buffer" }
        end,
        providers = {
            lsp = {
                fallbacks = function() return M.active() and {} or { "buffer" } end,
                transform_items = function(ctx, items)
                    local rime_items, others = {}, {}
                    local chunk = ctx.line:sub(1, ctx.cursor[2]):match("[a-zA-Z%p%d]+$") or ""
                    local composing = chunk:match("[a-zA-Z]") or chunk:match("&[%d]*$")
                    -- Capitalized words stay English, as in cmp-lsp-rimels.
                    local english = chunk:match("[A-Z][%w]*$")
                    local info = vim.inspect_pos(ctx.bufnr, ctx.cursor[1] - 1, math.max(0, ctx.cursor[2] - 1))
                    for _, capture in ipairs(info.treesitter) do
                        if capture.capture:match("^markup%.math") or capture.capture:match("^markup%.raw")
                            or capture.capture == "neorg.markup.inline_math"
                            or capture.capture == "neorg.markup.verbatim" then english = true end
                    end
                    for _, syntax in ipairs(info.syntax) do
                        if syntax.hl_group:match("[Mm]ath") or syntax.hl_group:match("[Cc]ode")
                            or syntax.hl_group == "pandocNoFormatted" then english = true end
                    end
                    composing = composing or M.punctuation_context(ctx.line, ctx.cursor[2])
                    for _, item in ipairs(items) do
                        if is_rime(item) then
                            if M.active(ctx.bufnr) and composing and not english then
                                table.insert(rime_items, item)
                            end
                        else
                            table.insert(others, item)
                        end
                    end
                    return #rime_items > 0 and rime_items or others
                end,
            },
        },
    }
end

return M
