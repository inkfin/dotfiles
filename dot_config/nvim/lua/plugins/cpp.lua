if _G.disable_plugins.cpp then
    return {}
end

return {
    -- Correctly setup lspconfig for clangd 🚀
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#clangd
                -- Ensure mason installs the server
                -- clangd configurations: https://clangd.llvm.org/config
                clangd = {
                    InlayHints = {
                        Designators = true,
                        Enabled = true,
                        ParameterNames = true,
                        DeducedTypes = true,
                    },
                    fallbackFlags = { "-std=c++20" },
                    keys = {
                        { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
                    },
                },
            },
        },
    },
    {
        "Civitasv/cmake-tools.nvim",
        enabled = false,
        keys = {
            { "<leader>cg", "<cmd>CMakeGenerate<cr>", desc = "CMake Generate" },
            { "<leader>cb", "<cmd>CMakeBuild<cr>", desc = "CMake Build" },
            { "<leader>cR", "<cmd>CMakeRun<cr>", desc = "CMake Run" },
            { "<leader>cT", "<cmd>CMakeRunTest<cr>", desc = "CMake Run Test" },
        },
        opts = function(_, opts)
            opts.cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" }
            opts.cmake_soft_link_compile_commands = true -- this will automatically make a soft link from compile commands file to project root dir

            if vim.fn.has("win32") then
                opts.cmake_build_directory = "build/${variant:buildType}"
            end

            opts.cmake_dap_configuration = { -- debug settings for cmake
                name = "cpp",
                type = "codelldb",
                request = "launch",
                stopOnEntry = false,
                runInTerminal = true,
                console = "integratedTerminal",
            }

            opts.cmake_executor = { -- executor to use
                name = "quickfix", -- name of the executor
                opts = {}, -- the options the executor will get, possible values depend on the executor type. See `default_opts` for possible values.
                default_opts = { -- a list of default and possible values for executors
                    quickfix = {
                        show = "always", -- "always", "only_on_error"
                        position = "belowright", -- "vertical", "horizontal", "leftabove", "aboveleft", "rightbelow", "belowright", "topleft", "botright", use `:h vertical` for example to see help on them
                        size = 10,
                        encoding = "utf-8", -- if encoding is not "utf-8", it will be converted to "utf-8" using `vim.fn.iconv`
                        auto_close_when_success = true, -- typically, you can use it with the "always" option; it will auto-close the quickfix buffer if the execution is successful.
                    },
                    toggleterm = {
                        direction = "float", -- 'vertical' | 'horizontal' | 'tab' | 'float'
                        close_on_exit = false, -- whether close the terminal when exit
                        auto_scroll = true, -- whether auto scroll to the bottom
                    },
                    overseer = {
                        new_task_opts = {
                            strategy = {
                                "toggleterm",
                                direction = "horizontal",
                                autos_croll = true,
                                quit_on_exit = "success",
                            },
                        }, -- options to pass into the `overseer.new_task` command
                        on_new_task = function(task)
                            require("overseer").open({ enter = false, direction = "right" })
                        end, -- a function that gets overseer.Task when it is created, before calling `task:start`
                    },
                    terminal = {
                        name = "Main Terminal",
                        prefix_name = "[CMakeTools]: ", -- This must be included and must be unique, otherwise the terminals will not work. Do not use a simple spacebar " ", or any generic name
                        split_direction = "horizontal", -- "horizontal", "vertical"
                        split_size = 11,

                        -- Window handling
                        single_terminal_per_instance = true, -- Single viewport, multiple windows
                        single_terminal_per_tab = true, -- Single viewport per tab
                        keep_terminal_static_location = true, -- Static location of the viewport if avialable

                        -- Running Tasks
                        start_insert = false, -- If you want to enter terminal with :startinsert upon using :CMakeRun
                        focus = false, -- Focus on terminal when cmake task is launched.
                        do_not_add_newline = false, -- Do not hit enter on the command inserted when using :CMakeRun, allowing a chance to review or modify the command before hitting enter.
                    }, -- terminal executor uses the values in cmake_terminal
                },
            }

            opts.cmake_runner = { -- runner to use
                name = "terminal", -- name of the runner
                opts = {}, -- the options the runner will get, possible values depend on the runner type. See `default_opts` for possible values.
                default_opts = { -- a list of default and possible values for runners
                    quickfix = {
                        show = "always", -- "always", "only_on_error"
                        position = "belowright", -- "bottom", "top"
                        size = 10,
                        encoding = "utf-8",
                        auto_close_when_success = true, -- typically, you can use it with the "always" option; it will auto-close the quickfix buffer if the execution is successful.
                    },
                    toggleterm = {
                        direction = "float", -- 'vertical' | 'horizontal' | 'tab' | 'float'
                        close_on_exit = false, -- whether close the terminal when exit
                        auto_scroll = true, -- whether auto scroll to the bottom
                    },
                    overseer = {
                        new_task_opts = {
                            strategy = {
                                "toggleterm",
                                direction = "horizontal",
                                autos_croll = true,
                                quit_on_exit = "success",
                            },
                        }, -- options to pass into the `overseer.new_task` command
                        on_new_task = function(task) end, -- a function that gets overseer.Task when it is created, before calling `task:start`
                    },
                    terminal = {
                        name = "Main Terminal",
                        prefix_name = "[CMakeTools]: ", -- This must be included and must be unique, otherwise the terminals will not work. Do not use a simple spacebar " ", or any generic name
                        split_direction = "horizontal", -- "horizontal", "vertical"
                        split_size = 11,

                        -- Window handling
                        single_terminal_per_instance = true, -- Single viewport, multiple windows
                        single_terminal_per_tab = true, -- Single viewport per tab
                        keep_terminal_static_location = true, -- Static location of the viewport if avialable

                        -- Running Tasks
                        start_insert = false, -- If you want to enter terminal with :startinsert upon using :CMakeRun
                        focus = false, -- Focus on terminal when cmake task is launched.
                        do_not_add_newline = false, -- Do not hit enter on the command inserted when using :CMakeRun, allowing a chance to review or modify the command before hitting enter.
                    },
                },
            }
        end,
    },
    {
        "p00f/clangd_extensions.nvim",
        opts = {
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
    -- formatters
    {
        "stevearc/conform.nvim",
        opts = {
            ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
            formatters = {
                ["cmake_format"] = {
                    prepend_args = { "--tab-size", "4" },
                },
            },
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
