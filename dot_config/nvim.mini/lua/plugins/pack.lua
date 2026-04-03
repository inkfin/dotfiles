-- ~/.config/nvim.mini/lua/plugins/pack.lua
-- vim.pack management helpers

-- List installed packs by scanning the pack directory on disk
vim.keymap.set("n", "<leader>l", function()
    local pack_root = vim.fn.stdpath("data") .. "/site/pack/core/opt"
    local dirs = vim.fn.glob(pack_root .. "/*", false, true)

    local lines = {}
    for _, path in ipairs(dirs) do
        local name = vim.fn.fnamemodify(path, ":t")
        table.insert(lines, string.format("%-40s  %s", name, path))
    end
    table.sort(lines)

    if #lines == 0 then
        lines = { "(no packs found under " .. pack_root .. ")" }
    end

    local header = { string.format("%-40s  %s", "NAME", "PATH"), string.rep("─", 80) }
    local all = vim.list_extend(header, lines)

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, all)
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype   = "text"

    local width  = math.min(120, vim.o.columns - 4)
    local height = math.min(#all + 2, vim.o.lines - 4)
    vim.api.nvim_open_win(buf, true, {
        relative  = "editor",
        width     = width,
        height    = height,
        row       = math.floor((vim.o.lines - height) / 2),
        col       = math.floor((vim.o.columns - width) / 2),
        style     = "minimal",
        border    = "rounded",
        title     = " Installed Packs (" .. #lines .. ") ",
        title_pos = "center",
    })
    vim.keymap.set("n", "q",     "<cmd>close<cr>", { buffer = buf, silent = true })
    vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
end, { desc = "List installed packs" })

-- Update all packs
vim.keymap.set("n", "<leader>pu", function()
    vim.notify("vim.pack: updating all plugins…", vim.log.levels.INFO)
    vim.pack.update()
end, { desc = "Update all packs" })
