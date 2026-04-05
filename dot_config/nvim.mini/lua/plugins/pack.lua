-- lua/plugins/pack.lua
-- vim.pack management helpers + thin wrappers used by every plugin file.
--
-- API
--   pack.add(spec)       – register plugin(s) with vim.pack
--   pack.load(modules)   – require a list of modules in order
--
-- Spec shapes accepted by pack.add():
--   "https://..."                                    simple URL
--   { src = "https://...", version = ">=1",          named spec
--     build = "make" }                               optional build command
--   { "https://...", { src = "...", build = "make" } }  list of the above

local M = {}

-- ─── Build-hook infrastructure ───────────────────────────────────────────────

local _hooks = {}          -- plugin-name → string|function
local _hook_registered = false

local function ensure_build_handler()
    if _hook_registered then return end
    _hook_registered = true
    vim.api.nvim_create_autocmd("PackChanged", {
        callback = function(ev)
            if ev.data.kind == "delete" then return end
            local name = ev.data.spec and ev.data.spec.name or ""
            local hook = _hooks[name]
            if not hook then return end

            if type(hook) == "function" then
                hook(ev.data.path)
            else
                -- string command, e.g. "make"
                local cmd = vim.split(hook, "%s+")
                if vim.fn.executable(cmd[1]) == 0 then
                    vim.notify(name .. ": build skipped ('" .. cmd[1] .. "' not found)",
                               vim.log.levels.WARN)
                    return
                end
                vim.notify(name .. ": building…", vim.log.levels.INFO)
                vim.system(cmd, { cwd = ev.data.path }, function(r)
                    if r.code == 0 then
                        vim.notify(name .. ": build succeeded", vim.log.levels.INFO)
                    else
                        vim.notify(name .. ": build FAILED\n" .. (r.stderr or ""),
                                   vim.log.levels.ERROR)
                    end
                end)
            end
        end,
    })
end

-- ─── pack.add ────────────────────────────────────────────────────────────────

local function add_one(spec)
    if type(spec) == "string" then
        vim.pack.add(spec)
        return
    end
    -- named spec table: { src, version?, build? }
    local pack_spec = { src = spec.src }
    local name = spec.src:match("([^/]+)$")
    if name then M._registered[name] = true end
    if spec.version then
        pack_spec.version = type(spec.version) == "string"
            and vim.version.range(spec.version)
            or  spec.version
    end
    vim.pack.add(pack_spec)

    if spec.build then
        local name = spec.src:match("([^/]+)$")
        if name then
            _hooks[name] = spec.build
            ensure_build_handler()
        end
    end
end

--- Register one or more plugins with vim.pack.
function M.add(spec)
    -- single URL or named spec
    if type(spec) == "string" or spec.src then
        add_one(spec)
        return
    end
    -- list of specs
    for _, s in ipairs(spec) do
        add_one(s)
    end
end

-- ─── pack.load ───────────────────────────────────────────────────────────────

--- Require a list of modules in order.
--- @param modules string[]
function M.load(modules)
    for _, mod in ipairs(modules) do
        require(mod)
    end
end

-- ─── Pack management keymaps ─────────────────────────────────────────────────

-- <leader>l  list installed packs in a float
vim.keymap.set("n", "<leader>l", function()
    local pack_root = vim.fn.stdpath("data") .. "/site/pack/core/opt"
    local dirs  = vim.fn.glob(pack_root .. "/*", false, true)
    local lines = {}
    for _, path in ipairs(dirs) do
        local name = vim.fn.fnamemodify(path, ":t")
        table.insert(lines, string.format("%-40s  %s", name, path))
    end
    table.sort(lines)
    if #lines == 0 then
        lines = { "(no packs found under " .. pack_root .. ")" }
    end

    local header = { string.format("%-40s  %s", "NAME", "PATH"), string.rep("─", 80) }
    local all = vim.list_extend(header, lines)

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, all)
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype   = "text"

    local width  = math.min(120, vim.o.columns - 4)
    local height = math.min(#all + 2, vim.o.lines - 4)
    vim.api.nvim_open_win(buf, true, {
        relative  = "editor",
        width     = width,
        height    = height,
        row       = math.floor((vim.o.lines   - height) / 2),
        col       = math.floor((vim.o.columns - width)  / 2),
        style     = "minimal",
        border    = "rounded",
        title     = " Installed Packs (" .. #lines .. ") ",
        title_pos = "center",
    })
    vim.keymap.set("n", "q",     "<cmd>close<cr>", { buffer = buf, silent = true })
    vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
end, { desc = "List installed packs" })

-- <leader>pu  update all packs
vim.keymap.set("n", "<leader>pu", function()
    vim.notify("vim.pack: updating all plugins…", vim.log.levels.INFO)
    vim.pack.update()
end, { desc = "Update all packs" })

return M
