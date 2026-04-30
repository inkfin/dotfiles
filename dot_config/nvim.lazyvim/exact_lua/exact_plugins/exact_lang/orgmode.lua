local is_win = vim.fn.has("win32") == 1

local function has_ts_parser(lang)
    for _, ext in ipairs({ "so", "dll", "dylib" }) do
        if #vim.api.nvim_get_runtime_file(("parser/%s.%s"):format(lang, ext), true) > 0 then
            return true
        end
    end
    return false
end

local function neorg_enabled()
    if _G.disable_plugins.org then
        return false
    end

    -- Neorg on Windows: skip LuaRocks (`tree-sitter-norg` stays disabled below) and
    -- do not rely on `:TSInstall norg` (often needs a full MSVC/MinGW toolchain).
    -- Community nightly builds ship `norg.so` only (no `norg_meta` in that zip):
    --   https://github.com/anasrar/nvim-treesitter-parser-bin/releases/download/windows/all.zip
    -- Extract `norg.so` into `stdpath('data')/lazy/nvim-treesitter/parser/` (same
    -- layout as lazy.nvim; Neovim accepts the `.so` name on Windows for these builds).
    -- `norg_meta` is optional here: omit `core.summary` when it is missing so Neorg
    -- still loads for normal editing without local compilation.
    if is_win then
        return has_ts_parser("norg")
    end

    return true
end

local function warn_missing_windows_parsers()
    if not is_win or _G.disable_plugins.org then
        return
    end

    local parser_dir = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/parser"
    local prebuilt = "https://github.com/anasrar/nvim-treesitter-parser-bin/releases/download/windows/all.zip"

    if not has_ts_parser("norg") then
        if _G.__neorg_windows_norg_warned then
            return
        end
        _G.__neorg_windows_norg_warned = true
        vim.schedule(function()
            vim.notify(
                "Neorg disabled on Windows: no Tree-sitter `norg` parser. "
                    .. "Without a C toolchain, extract `norg.so` from the prebuilt zip into:\n"
                    .. parser_dir
                    .. "\nZip: "
                    .. prebuilt,
                vim.log.levels.WARN
            )
        end)
        return
    end

    if not has_ts_parser("norg_meta") and not _G.__neorg_windows_meta_warned then
        _G.__neorg_windows_meta_warned = true
        vim.schedule(function()
            vim.notify(
                "Neorg: `norg_meta` parser not found — workspace summary (core.summary) is disabled. "
                    .. "Common prebuilt packs include `norg` only; `norg_meta` usually needs a one-off build "
                    .. "(e.g. WSL or a machine with tree-sitter CLI) copied to the same parser directory.",
                vim.log.levels.INFO
            )
        end)
    end
end

if not neorg_enabled() then
    warn_missing_windows_parsers()
    return {}
end

warn_missing_windows_parsers()

return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            -- add tsx and treesitter
            opts.highlight.enable = true
            if not is_win and type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, { "norg" })
            end
            if opts.highlight.additional_vim_regex_highlighting == nil then
                opts.highlight.additional_vim_regex_highlighting = {}
            end
            vim.list_extend(opts.highlight.additional_vim_regex_highlighting, { "norg" })
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        ---@param opts cmp.ConfigSchema
        opts = function(_, opts)
            local cmp = require("cmp")
            opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "neorg" } }))
        end,
    },
    {
        "nvim-neorg/neorg",
        version = "*",
        pkg = false,
        lazy = false,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/nvim-nio",
            "MunifTanjim/nui.nvim",
            "pysan3/pathlib.nvim",
            "nvim-neorg/lua-utils.nvim",
            { "nvim-neorg/tree-sitter-norg", enabled = not vim.fn.has("win32") },
        },
        -- treesitter fix <https://github.com/nvim-neorg/neorg/issues/1715#issuecomment-3524433687>
        build = function()
            -- run command manually
            -- ln -sf ~/.local/share/nvim/lazy-rocks/tree-sitter-norg/lib/lua/5.1/parser/norg.so ~/.local/share/nvim/site/parser/norg.so
        end,
        opts = function(_, opts)
            opts.load = {
                -- editing
                -- https://github.com/nvim-neorg/neorg/wiki#default-modules
                ["core.defaults"] = {},
                -- https://github.com/nvim-neorg/neorg/wiki/Concealer
                ["core.concealer"] = {
                    config = {
                        icon_preset = "basic",
                        icons = {
                            code_block = {
                                spell_check = false,
                            },
                        },
                    },
                },
                ["core.summary"] = {},
                ["core.dirman"] = {
                    config = {
                        workspaces = {
                            homenotes = "~/Notes/HomeNotes",
                            worknotes = "~/Notes/WorkNotes",
                            studynotes = "~/Notes/StudyNotes",
                        },
                    },
                },
                -- completion
                ["core.completion"] = {
                    config = {
                        engine = "nvim-cmp",
                    },
                },
                -- exporting
                ["core.export"] = {
                    config = {
                        export_dir = "dist",
                    },
                },
                ["core.export.markdown"] = {
                    config = {
                        extensions = "all",
                    },
                },
                -- cool features
            }

            -- `core.summary` uses the `norg_meta` grammar; skip it when that parser is absent.
            if is_win and not has_ts_parser("norg_meta") then
                opts.load["core.summary"] = nil
            end

            if vim.g.support_image then
                opts.load["core.latex.renderer"] = {
                    config = {
                        render_on_enter = true,
                    },
                }
            end

            -- treesitter fix <https://github.com/nvim-neorg/neorg/issues/1715#issuecomment-3367507386>
            -- vim.api.nvim_create_autocmd("FileType", {
            --     pattern = { "norg" },
            --     callback = function()
            --         if pcall(vim.treesitter.start) then
            --             vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            --             vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            --         end
            --     end,
            -- })

            vim.api.nvim_create_autocmd({ "FileType" }, {
                pattern = { "norg" },
                callback = function()
                    require("which-key").add({
                        buffer = true,
                        mode = { "n", "v" },
                        { "<localleader>t", group = "norg [T]ask" },
                        { "<localleader>i", group = "norg [I]nsert" },
                        { "<localleader>o", group = "norg [O]pen" },
                        { "<localleader>c", group = "norg [C]ode block" },
                        { "<localleader>n", group = "norg [N]ew" },
                        { "<localleader>l", group = "norg [L]ist" },
                    })
                end,
            })
        end,
        -- stylua: ignore
        keys = {
            -- <C-Space> was occupied, use combination keys
            { "<localleader>tx", mode = { "n" }, "<Plug>(neorg.qol.todo-items.todo.task-cycle)",         desc = "task-cycle",         ft = "norg" },
            { "<localleader>tX", mode = { "n" }, "<Plug>(neorg.qol.todo-items.todo.task-cycle-reverse)", desc = "task-cycle-reverse", ft = "norg" },
            -- Neorg prefix
            { "<localleader>;",  mode = { "n" }, ":Neorg ",                 desc = "Neorg command",     ft = "norg" },
            -- workspaces
            { "<leader>on",      mode = { "n" }, "<CMD>Neorg workspace homenotes<CR>", desc = "Norg worknotes"},
            { "<localleader>or", mode = { "n" }, "<CMD>Neorg return<CR>",   desc = "Norg return",       ft = "norg" },
            { "<localleader>ow", mode = { "n" }, ":Neorg workspace ",       desc = "Norg workspace",    ft = "norg" },
            { "<localleader>oi", mode = { "n" }, "<CMD>Neorg index<CR>",    desc = "Norg index",        ft = "norg" },

            -- meta-data
            { "<localleader>im", mode = { "n" }, "<CMD>Neorg inject-metadata<CR>",     desc = "Inject Metadata", ft = "norg" },
            -- summary
            { "<localleader>is", mode = { "n" }, ":Neorg generate-workspace-summary ", desc = "Generate workspace summary", ft = "norg" },

        },
    },
}

-- vim: set ft=lua:
