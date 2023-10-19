-- Debug plugins settings
return {
    {
        "mfussenegger/nvim-dap",
        -- stylua: ignore
        keys = {
            -- default keymaps
            { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
            { "<leader>dL", function() require("dap").list_breakpoints() end, desc = "List Breakpoints" },
            { "<leader>dD", function() require("dap").clear_breakpoints() end, desc = "!!Remove all breakpoints" },
            { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
            { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
            { "<leader>dg", function() require("dap").goto_() end, desc = "Go to line (no execute)" },
            { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
            { "<leader>dj", function() require("dap").down() end, desc = "Down" },
            { "<leader>dk", function() require("dap").up() end, desc = "Up" },
            { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
            { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
            { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
            { "<leader>dI", function() require("dap").reverse_continue() end, desc = "Step Back*" }, -- requires debugger reverse debugging support
            { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
            { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
            { "<leader>ds", function() require("dap").session() end, desc = "Session" },
            { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
            { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
            -- vscode keymap
            { "<F6>", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
            { "<F5>", function() require("dap").continue() end, desc = "Continue" },
            { "<S-F5>", function() require("dap").terminate(); require("dap").repl.close(); require("dapui").close() end, desc = "Terminate" }, -- this won't work in terminal
            { "<F9>", function() require("dap").step_over() end, desc = "Step Over" },
            { "<F8>", function() require("dap").step_into() end, desc = "Step Into" },
            { "<S-F8>", function() require("dap").step_out() end, desc = "Step Out" }, -- this won't work in terminal
            { "<F7>", function() require("dap").reverse_continue() end, desc = "Step Back*" }, -- requires debugger reverse debugging support
            { "<leader>dR", function() require("dap").restart() end, desc = "Restart" },
            { "<C-S-F5>", function() require("dap").restart() end, desc = "Restart" },
        },
    },
    {
        "rcarriga/nvim-dap-ui",
        opts = {
            layouts = {
                {
                    elements = {
                        {
                            id = "scopes",
                            size = 0.25,
                        },
                        {
                            id = "stacks",
                            size = 0.25,
                        },
                        {
                            id = "breakpoints",
                            size = 0.25,
                        },
                        {
                            id = "watches",
                            size = 0.25,
                        },
                    },
                    position = "left",
                    size = 40,
                },
                {
                    elements = {
                        {
                            id = "repl",
                            size = 0.5,
                        },
                        {
                            id = "console",
                            size = 0.5,
                        },
                    },
                    position = "bottom",
                    size = 20,
                },
            },
        },
    },
}
