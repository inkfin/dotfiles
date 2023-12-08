return {
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
                },
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
                        return vim.g.cmake_get_exec_directory()
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
                        return vim.g.cmake_get_exec_directory()
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
}
