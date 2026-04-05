-- ~/.config/nvim.mini/lua/plugins/dap.lua
-- nvim-dap: Debug Adapter Protocol client
-- nvim-dap-ui: UI panels (scopes, stacks, breakpoints, watches, repl, console)
-- Docs: https://github.com/mfussenegger/nvim-dap
--       https://github.com/rcarriga/nvim-dap-ui

require("pack").add({
    "https://github.com/mfussenegger/nvim-dap",
    "https://github.com/rcarriga/nvim-dap-ui",
    "https://github.com/nvim-neotest/nvim-nio",  -- required by nvim-dap-ui
})

local ok_dap, dap = pcall(require, "dap")
if not ok_dap then return end

local ok_ui, dapui = pcall(require, "dapui")
if not ok_ui then return end

-- ─── dap-ui layout ───────────────────────────────────────────────────────────

dapui.setup({
    layouts = {
        {
            -- Left panel: variable scopes, call stack, breakpoints, watches
            elements = {
                { id = "scopes",      size = 0.25 },
                { id = "stacks",      size = 0.25 },
                { id = "breakpoints", size = 0.25 },
                { id = "watches",     size = 0.25 },
            },
            position = "left",
            size = 40,
        },
        {
            -- Bottom panel: REPL + program console
            elements = {
                { id = "repl",    size = 0.5 },
                { id = "console", size = 0.5 },
            },
            position = "bottom",
            size = 20,
        },
    },
})

-- Auto-open/close dap-ui when a debug session starts/ends
dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end

-- ─── codelldb adapter (C / C++) ──────────────────────────────────────────────

dap.set_log_level("WARN")

if not dap.adapters["codelldb"] then
    dap.adapters["codelldb"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
            command = "codelldb",
            args    = { "--port", "${port}" },
        },
    }
end

dap.configurations.cpp = {
    {
        type    = "codelldb",
        request = "launch",
        name    = "Launch executable",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd            = "${workspaceFolder}",
        stopOnEntry    = false,
        runInTerminal  = false,
    },
    {
        type      = "codelldb",
        request   = "attach",
        name      = "Attach to process",
        processId = require("dap.utils").pick_process,
        cwd       = "${workspaceFolder}",
    },
}

-- C shares the same configurations as C++
dap.configurations.c = dap.configurations.cpp

-- ─── Keymaps ─────────────────────────────────────────────────────────────────

local map = vim.keymap.set

-- Breakpoints
map("n", "<leader>db",  function() dap.toggle_breakpoint() end,                                                { desc = "Toggle Breakpoint" })
map("n", "<leader>dB",  function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,             { desc = "Breakpoint Condition" })
map("n", "<leader>dL",  function() dap.list_breakpoints() end,                                                 { desc = "List Breakpoints" })
map("n", "<leader>dD",  function() dap.clear_breakpoints() end,                                                { desc = "Remove All Breakpoints" })

-- Execution control
map("n", "<leader>dc",  function() dap.continue() end,          { desc = "Continue" })
map("n", "<leader>dC",  function() dap.run_to_cursor() end,     { desc = "Run to Cursor" })
map("n", "<leader>dg",  function() dap.goto_() end,             { desc = "Go to Line (no execute)" })
map("n", "<leader>di",  function() dap.step_into() end,         { desc = "Step Into" })
map("n", "<leader>do",  function() dap.step_out() end,          { desc = "Step Out" })
map("n", "<leader>dO",  function() dap.step_over() end,         { desc = "Step Over" })
map("n", "<leader>dI",  function() dap.reverse_continue() end,  { desc = "Step Back (requires reverse debug support)" })
map("n", "<leader>dp",  function() dap.pause() end,             { desc = "Pause" })
map("n", "<leader>dl",  function() dap.run_last() end,          { desc = "Run Last" })
map("n", "<leader>dR",  function() dap.restart() end,           { desc = "Restart" })
map("n", "<leader>dt",  function() dap.terminate() end,         { desc = "Terminate" })

-- Frame navigation
map("n", "<leader>dj",  function() dap.down() end,   { desc = "Down (frame)" })
map("n", "<leader>dk",  function() dap.up() end,     { desc = "Up (frame)" })

-- Misc
map("n", "<leader>ds",  function() dap.session() end,                  { desc = "Session Info" })
map("n", "<leader>dr",  function() dap.repl.toggle() end,              { desc = "Toggle REPL" })
map("n", "<leader>dw",  function() require("dap.ui.widgets").hover() end, { desc = "Widgets (hover)" })
map("n", "<leader>du",  function() dapui.toggle() end,                 { desc = "Toggle DAP UI" })

-- VS Code-style F-key bindings
map("n", "<F5>",    function() dap.continue() end,      { desc = "DAP Continue" })
map("n", "<F9>",    function() dap.toggle_breakpoint() end, { desc = "DAP Toggle Breakpoint" })
map("n", "<F10>",   function() dap.step_over() end,     { desc = "DAP Step Over" })
map("n", "<F11>",   function() dap.step_into() end,     { desc = "DAP Step Into" })
map("n", "<S-F5>",  function() dap.terminate(); dap.repl.close(); dapui.close() end, { desc = "DAP Terminate" })
map("n", "<S-F10>", function() dap.reverse_continue() end, { desc = "DAP Step Back" })
map("n", "<S-F11>", function() dap.step_out() end,      { desc = "DAP Step Out" })
map("n", "<C-F5>",  function() dap.restart() end,       { desc = "DAP Restart" })

-- which-key group label
local ok_wk, wk = pcall(require, "which-key")
if ok_wk then
    wk.add({ { "<leader>d", group = "debug" } })
end
