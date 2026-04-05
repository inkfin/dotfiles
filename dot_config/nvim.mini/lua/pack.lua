-- lua/pack.lua
-- Thin wrappers around vim.pack used by every plugin file.
--
-- API
--   pack.add(spec)     – register plugin(s) with vim.pack
--   pack.load(modules) – require a list of modules in order
--
-- Spec shapes accepted by pack.add():
--   "https://..."
--   { src = "https://...", version = ">=1", build = "make" }
--   { "https://...", { src = "...", build = "make" }, ... }

local M = {}

-- Track every plugin name registered this session.
-- The trailing segment of the URL (e.g. "which-key.nvim" from
-- "https://github.com/folke/which-key.nvim") is the directory name
-- vim.pack uses on disk, so it can be diffed against the pack opt/ folder
-- by :PackClean to find orphaned plugins.
M._registered = {}

-- ─── Build-hook infrastructure ───────────────────────────────────────────────

local _hooks = {}          -- plugin-name → string|function
local _hook_registered = false

-- Lazily register a single PackChanged autocmd the first time any plugin
-- declares a build hook. Fires after vim.pack installs or updates a plugin.
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
                -- Lua function hook: called with the plugin's install path
                hook(ev.data.path)
            else
                -- String hook: treated as a shell command (e.g. "make")
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

-- Handle a single spec (string URL or named table).
local function add_one(spec)
    if type(spec) == "string" then
        vim.pack.add({ spec })
        -- Record the trailing URL segment as the on-disk plugin name
        local name = spec:match("([^/]+)$")
        if name then M._registered[name] = true end
        return
    end

    -- Named spec table ─────────────────────────────────────────────────────
    local pack_spec = { src = spec.src }
    local name = spec.src:match("([^/]+)$")
    if name then M._registered[name] = true end

    -- Optional version constraint: accept a range string (">=1.0") or a
    -- pre-parsed vim.version range object
    if spec.version then
        pack_spec.version = type(spec.version) == "string"
            and vim.version.range(spec.version)
            or  spec.version
    end
    vim.pack.add({ pack_spec })

    -- Optional build hook: run after install/update
    if spec.build then
        local bname = spec.src:match("([^/]+)$")
        if bname then
            _hooks[bname] = spec.build
            ensure_build_handler()
        end
    end
end

--- Register one or more plugins with vim.pack.
function M.add(spec)
    -- Single URL string or single named-table spec
    if type(spec) == "string" or spec.src then
        add_one(spec)
        return
    end
    -- List of specs: iterate and register each one
    for _, s in ipairs(spec) do
        add_one(s)
    end
end

-- ─── pack.load ───────────────────────────────────────────────────────────────

--- Require a list of modules in order.
--- Centralises all plugin loading so init.lua stays a flat ordered list.
--- @param modules string[]
function M.load(modules)
    for _, mod in ipairs(modules) do
        require(mod)
    end
end

return M
