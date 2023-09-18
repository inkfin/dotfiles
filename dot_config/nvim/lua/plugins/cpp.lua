return {
    -- Install code highlighter
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            if type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, {
                    "c",
                    "cpp",
                    "cmake",
                })
            end
        end,
    },
    -- Install lsp and dap
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            if type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, {
                    "codelldb",
                    "clang-format",
                })
            end
        end,
    },

    -- Correctly setup lspconfig for clangd 🚀
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                -- Ensure mason installs the server
                clangd = {
                    keys = {
                        { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
                    },
                    root_dir = function(fname)
                        -- using a root .clang-format or .clang-tidy file messes up projects, so remove them
                        return require("lspconfig.util").root_pattern(
                            "Makefile",
                            "CMakeLists.txt",
                            "configure.ac",
                            "configure.in",
                            "config.h.in",
                            "meson.build",
                            "meson_options.txt",
                            "build.ninja"
                        )(fname) or require("lspconfig.util").root_pattern(
                            "compile_commands.json",
                            "compile_flags.txt"
                        )(fname) or require("lspconfig.util").find_git_ancestor(fname)
                    end,
                    capabilities = {
                        offsetEncoding = { "utf-16" },
                    },
                    cmd = {
                        "clangd",
                        "--background-index",
                        "--clang-tidy",
                        "--header-insertion=iwyu",
                        "--completion-style=detailed",
                        "--function-arg-placeholders",
                        "--fallback-style=llvm",
                    },
                    init_options = {
                        usePlaceholders = true,
                        completeUnimported = true,
                        clangdFileStatus = true,
                    },
                },
            },
            -- FIXIT: Issue (https://github.com/LazyVim/LazyVim/pull/1308), merge appending
            -- remove this after it get merged
            setup = {
                clangd = function(_, opts)
                    local clangd_ext_opts = require("lazyvim.util").opts("clangd_extensions.nvim")
                    require("clangd_extensions").setup(
                        vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts })
                    )
                    return false -- change true to false
                end,
            },
        },
    },
    {
        "p00f/clangd_extensions.nvim",
        opts = {
            inlay_hints = {
                inline = vim.fn.has("nvim-0.10") == 1,
            },
            -- ast = {
            --     -- These are unicode, should be available in any font
            --     role_icons = {
            --         type = "🄣",
            --         declaration = "🄓",
            --         expression = "🄔",
            --         statement = ";",
            --         specifier = "🄢",
            --         ["template argument"] = "🆃",
            --     },
            --     kind_icons = {
            --         Compound = "🄲",
            --         Recovery = "🅁",
            --         TranslationUnit = "🅄",
            --         PackExpansion = "🄿",
            --         TemplateTypeParm = "🅃",
            --         TemplateTemplateParm = "🅃",
            --         TemplateParamObject = "🅃",
            --     },
            -- },
        },
    },

    -- Debugger settings
    {
        "mfussenegger/nvim-dap",
        opts = function()
            local dap = require("dap")
            dap.set_log_level("debug")

            if not dap.adapters["codelldb"] then
                require("dap").adapters["codelldb"] = {
                    type = "server",
                    host = "localhost",
                    port = "${port}",
                    executable = {
                        command = "codelldb",
                        args = {
                            "--port",
                            "${port}",
                        },
                    },
                }
            end

            -- CPP settings
            dap.configurations.cpp = {
                {
                    type = "codelldb",
                    request = "launch",
                    name = "Launch executable file",
                    program = function()
                        return vim.g.cmake_get_exec_path()
                    end,
                    cwd = function()
                        -- working in Windows, change cwd to binary folder
                        local path = vim.fn.fnamemodify(vim.g["cmake_last_exec_path"], ":h")
                        print("Program executed in: " .. path)
                        return path
                        -- return "${workspaceFolder}"
                    end,
                },
                {
                    type = "codelldb",
                    request = "launch",
                    name = "Rebuild and Launch",
                    program = function()
                        if vim.fn.confirm("Should I recompile first?", "&yes\n&no", 2) == 1 then
                            vim.g.cmake_build_project()
                        end
                        return vim.g.cmake_get_exec_path()
                    end,
                    cwd = function()
                        -- working in Windows, change cwd to binary folder
                        local path = vim.fn.fnamemodify(vim.g["cmake_last_exec_path"], ":h")
                        print("Program executed in: " .. path)
                        return path
                    end,
                },
                {
                    type = "codelldb",
                    request = "attach",
                    name = "Attach to process",
                    processId = require("dap.utils").pick_process,
                    cwd = "${workspaceFolder}",
                },
            }

            -- Add support for launch.json
            require("dap.ext.vscode").load_launchjs(nil, { codelldb = { "c", "cpp" } }) -- default path is ${workspaceFolder}/.vscode/launch.json

            -- C settings
            dap.configurations.c = dap.configurations.cpp
        end,
    },

    -- formatter config
    {
        "jose-elias-alvarez/null-ls.nvim",
        opts = function(_, opts)
            if type(opts.sources) == "table" then
                local nls = require("null-ls")
                vim.list_extend(opts.sources, {
                    nls.builtins.formatting.clang_format,
                })
            end
        end,
    },
}
