-- lua/pack.lua
-- Thin wrappers around vim.pack used by every plugin file.
--
-- API
--   pack.add(spec)     – register plugin(s) with vim.pack
--   pack.load(modules) – require a list of plugin modules in two phases
--
-- Spec shapes accepted by pack.add():
--   "https://..."
--   { src = "https://...", version = ">=1", build = "make" }
--   { "https://...", { src = "...", build = "make" }, ... }
--
-- How two-phase loading works:
--   Phase 1 (collecting):  each plugin module is required; pack.add() buffers
--     specs and hooks without calling vim.pack.add(), then raises a sentinel
--     error so pack.load() marks it for re-running in Phase 2.
--   Flush: vim.pack.add() is called ONCE with every collected spec. All hooks
--     are already registered, so PackChanged fires with correct hook data even
--     for lockfile-based installs triggered by the very first add() call.
--   Phase 2 (configure):  modules that errored in Phase 1 are re-required.
--     All plugins are now on disk and in rtp, so require("plugin") succeeds.

local M = {}

-- Every plugin name (trailing URL segment) registered this session.
-- Used by :PackClean to detect orphaned plugin directories.
M._registered = {}

local function notify_safe(msg, level)
    vim.schedule(function()
        vim.notify(msg, level)
    end)
end

local function plugin_name(src)
    return type(src) == "string" and src:match("([^/]+)$") or nil
end

-- ─── Build-hook infrastructure ───────────────────────────────────────────────

local _hooks     = {}   -- plugin-name → build command or function
local _all_specs = {}   -- accumulated vim.pack specs (flushed once)

-- PackChanged is registered NOW, before any vim.pack.add() call, so it is
-- always in place for lockfile-based installs that fire during the first add.
vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        if ev.data.kind == "delete" then return end
        local name  = ev.data.spec and ev.data.spec.name or ""
        -- Build command travels with the spec (data.build) and is also
        -- mirrored in _hooks; either source works.
        local build = (ev.data.spec.data and ev.data.spec.data.build)
                      or _hooks[name]
        if not build then return end

        if type(build) == "function" then
            build(ev.data.path)
        else
            local cmd = vim.split(build, "%s+")
            if vim.fn.executable(cmd[1]) == 0 then
                notify_safe(name .. ": build skipped ('" .. cmd[1] .. "' not found)",
                            vim.log.levels.WARN)
                return
            end
            notify_safe(name .. ": building...", vim.log.levels.INFO)
            vim.system(cmd, { cwd = ev.data.path }, function(r)
                if r.code == 0 then
                    notify_safe(name .. ": build succeeded", vim.log.levels.INFO)
                else
                    notify_safe(name .. ": build FAILED\n" .. (r.stderr or ""),
                                vim.log.levels.ERROR)
                end
            end)
        end
    end,
})

-- ─── Internal state ──────────────────────────────────────────────────────────

-- True while pack.load() is in Phase 1.  pack.add() buffers specs and raises
-- a sentinel error so the caller knows it must be re-run in Phase 2.
M._collecting = false

-- ─── pack.add (internal) ─────────────────────────────────────────────────────

local function add_one(spec)
    if type(spec) == "string" then
        local name = plugin_name(spec)
        if name then M._registered[name] = true end

        if M._collecting then
            table.insert(_all_specs, spec)
        else
            vim.pack.add({ spec })
        end
        return
    end

    -- Named spec table ─────────────────────────────────────────────────────
    local name = plugin_name(spec.src)
    if name then M._registered[name] = true end

    -- Register hook pre-emptively so PackChanged can find it even before the
    -- individual add_one() for this plugin runs.
    if spec.build and name then
        _hooks[name] = spec.build
    end

    local pack_spec = { src = spec.src }

    -- Embed build command in spec.data so it travels with the spec and is
    -- available in ev.data.spec.data inside the PackChanged callback.
    if spec.build then
        pack_spec.data = { build = spec.build }
    end

    -- Optional version constraint
    if spec.version then
        pack_spec.version = type(spec.version) == "string"
            and vim.version.range(spec.version)
            or  spec.version
    end

    if M._collecting then
        table.insert(_all_specs, pack_spec)
    else
        vim.pack.add({ pack_spec })
    end
end

--- Register one or more plugins with vim.pack.
function M.add(spec)
    if type(spec) == "string" or spec.src then
        add_one(spec)
    else
        -- List of specs: collect all before possibly erroring
        for _, s in ipairs(spec) do
            add_one(s)
        end
    end

    -- In Phase 1, signal to pack.load() that this module must be re-run in
    -- Phase 2 (plugins not yet packadd'd so require() would fail).
    if M._collecting then
        error("pack: collecting phase — re-run required", 0)
    end
end

-- ─── pack.load ───────────────────────────────────────────────────────────────

--- Load a list of modules in two phases so that build hooks are always
--- registered before the first vim.pack.add() call.
--- @param modules string[]
function M.load(modules)
    -- ── Phase 1: collect specs & hooks ──────────────────────────────────────
    -- Require every module.  Modules that call pack.add() will buffer their
    -- specs and then raise a sentinel error; we catch it with pcall and mark
    -- those modules for re-running in Phase 2.  Pure config modules (options,
    -- autocmds, keymaps) succeed and are skipped in Phase 2.
    local needs_phase2 = {}
    M._collecting = true
    for _, mod in ipairs(modules) do
        local ok = pcall(require, mod)
        if not ok then
            needs_phase2[mod] = true
        end
        -- Clear the module cache so Phase 2 can re-require it cleanly.
        package.loaded[mod] = nil
    end
    M._collecting = false

    -- ── Flush: single vim.pack.add() with every spec ─────────────────────────
    -- All _hooks entries are populated now, so PackChanged (fired for any
    -- lockfile-based install) will find the correct build command.
    if #_all_specs > 0 then
        vim.pack.add(_all_specs)
    end

    -- ── Phase 2: configure ───────────────────────────────────────────────────
    -- Re-require only modules that errored in Phase 1.  All plugins are on
    -- disk and in rtp now, so require("plugin") succeeds.
    for _, mod in ipairs(modules) do
        if needs_phase2[mod] then
            require(mod)
        end
    end
end

return M
