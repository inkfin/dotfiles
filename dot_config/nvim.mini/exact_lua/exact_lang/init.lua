-- ~/.config/nvim.mini/lua/lang/init.lua
-- Central registry for language modules.
--
-- Each `lang/*.lua` module returns a small spec table:
-- - `mason_lspconfig`: lspconfig server ids recognized by mason-lspconfig.
-- - `mason_packages`: raw Mason package names for servers Mason knows about
--   but mason-lspconfig does not map yet.
-- - `treesitter`: parser names to install when this language is enabled.
-- - `setup()`: language-specific LSP/plugin setup.
--
-- The plugin layer only asks this module for enabled specs. That keeps
-- `plugins/lsp.lua` generic and lets each language file own both its install
-- entries and its actual server configuration.

local M = {}

-- Keep this list ordered so startup behavior is deterministic and easy to scan.
local registry = {
    { key = "c",      module = "lang.c" },
    { key = "c3",     module = "lang.c3" },
    { key = "proto",  module = "lang.proto" },
    { key = "lua_ls", module = "lang.lua_ls" },
    { key = "markdown", module = "lang.markdown" },
    { key = "python", module = "lang.python" },
    { key = "rust",   module = "lang.rust" },
    { key = "go",     module = "lang.go" },
    { key = "zig",    module = "lang.zig" },
    { key = "latex",  module = "lang.latex" },
}

local function extend_unique(list, seen, items)
    if type(items) ~= "table" then return end
    for _, item in ipairs(items) do
        if not seen[item] then
            seen[item] = true
            table.insert(list, item)
        end
    end
end

local function is_enabled(lang_cfg, key)
    return lang_cfg[key] == true
end

function M.collect()
    local ok_local, local_cfg = pcall(require, "local")
    local lang_cfg = ok_local and local_cfg.lang or {}
    local specs = {
        ensure_servers = {},
        ensure_packages = {},
        ensure_treesitter = {},
        loaded = {},
    }
    local seen_servers = {}
    local seen_packages = {}
    local seen_treesitter = {}

    for _, entry in ipairs(registry) do
        if is_enabled(lang_cfg, entry.key) then
            local ok, spec = pcall(require, entry.module)
            if ok and type(spec) == "table" then
                extend_unique(specs.ensure_servers, seen_servers, spec.mason_lspconfig)
                extend_unique(specs.ensure_packages, seen_packages, spec.mason_packages)
                extend_unique(specs.ensure_treesitter, seen_treesitter, spec.treesitter)
                table.insert(specs.loaded, spec)
            end
        end
    end

    return specs
end

return M
