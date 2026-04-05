-- ~/.config/nvim.mini/lua/plugins/terminal.lua
-- All terminals via snacks.nvim (terminal = { enabled = true } in snacks.lua)

-- <C-/> — persistent bottom shell
-- A fixed env key pins the terminal id (which includes cwd by default) so the
-- same shell is reused regardless of which buffer is current when you toggle.
local function toggle_shell()
    Snacks.terminal.toggle(nil, {
        env = { NVIM_BOTTOM_SHELL = "1" },
        win = { position = "bottom", height = 0.35 },
    })
end

vim.keymap.set({ "n", "t" }, "<C-/>", toggle_shell,
    { silent = true, desc = "Toggle bottom terminal" })
-- Some terminals send <C-_> for <C-/>
vim.keymap.set({ "n", "t" }, "<C-_>", toggle_shell,
    { silent = true, desc = "Toggle bottom terminal" })

-- <leader>gg — lazygit
-- Snacks writes a lazygit config with editPreset="nvim-remote" so pressing 'e'
-- forwards the file to the outer Neovim session via the inherited $NVIM socket.
vim.keymap.set("n", "<leader>gg", function()
    if vim.fn.executable("lazygit") == 0 then
        vim.notify("lazygit not found in PATH", vim.log.levels.ERROR)
        return
    end
    Snacks.lazygit()
end, { silent = true, desc = "Lazygit" })

-- <leader>yy — yazi (--chooser-file integration)
-- Yazi does not call $EDITOR; it writes chosen paths to a tmp file on exit.
-- We open a fresh terminal each invocation (tmp path changes), attach a
-- TermClose listener, then read + open the chosen files in the outer session.
vim.keymap.set("n", "<leader>yy", function()
    if vim.fn.executable("yazi") == 0 then
        vim.notify("yazi not found in PATH", vim.log.levels.ERROR)
        return
    end

    local tmp = vim.fn.tempname()
    local term = Snacks.terminal.open("yazi --chooser-file " .. tmp, {
        -- unique env makes the tid unique so toggle doesn't reuse a stale instance
        env = { YAZI_TMP = tmp },
        win = {
            position = "float",
            border   = "rounded",
            width    = 0.9,
            height   = 0.85,
        },
    })
    term:on("TermClose", function()
        vim.schedule(function()
            local ok, lines = pcall(vim.fn.readfile, tmp)
            vim.fn.delete(tmp)
            if ok and lines and #lines > 0 and lines[1] ~= "" then
                for _, file in ipairs(lines) do
                    vim.cmd("edit " .. vim.fn.fnameescape(file))
                end
            end
        end)
    end, { buf = true })
end, { silent = true, desc = "Yazi file manager" })

-- <C-Q> in any terminal buffer — exit terminal mode
vim.keymap.set("t", "<C-Q>", "<C-\\><C-n>",
    { silent = true, desc = "Exit terminal mode" })
