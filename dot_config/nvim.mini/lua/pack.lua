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
        vim.pack.add({ spec })
        return
    end
    local pack_spec = { src = spec.src }
    if spec.version then
        pack_spec.version = type(spec.version) == "string"
            and vim.version.range(spec.version)
            or  spec.version
    end
    vim.pack.add({ pack_spec })

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
    if type(spec) == "string" or spec.src then
        add_one(spec)
        return
    end
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

return M
