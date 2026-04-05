-- lua/plugins/pack_ext.lua
-- Stopgap extensions for vim.pack until Neovim ships its own plugin UI.
-- Remove this file once :PackList / :PackUpdate exist natively.

local pack_root = vim.fn.stdpath("data") .. "/site/pack/core/opt"

-- Returns names of every directory currently in the pack opt/ folder.
local function installed_names()
    local dirs = vim.fn.glob(pack_root .. "/*", false, true)
    local names = {}
    for _, path in ipairs(dirs) do
        table.insert(names, vim.fn.fnamemodify(path, ":t"))
    end
    table.sort(names)
    return names
end

-- :PackClean  – remove plugins on disk that are no longer registered via pack.add()
vim.api.nvim_create_user_command("PackClean", function()
    local registered = require("pack")._registered
    local removed = {}

    for _, name in ipairs(installed_names()) do
        if not registered[name] then
            vim.fn.delete(pack_root .. "/" .. name, "rf")
            table.insert(removed, name)
        end
    end

    if #removed == 0 then
        vim.notify("PackClean: nothing to remove", vim.log.levels.INFO)
    else
        vim.notify("PackClean: removed " .. #removed .. " plugin(s):\n  " .. table.concat(removed, "\n  "),
            vim.log.levels.INFO)
    end
end, { desc = "Remove plugins no longer registered with pack.add()" })

-- :PackRemove <name>  – delete a specific plugin from disk by name
--   Tab-completion lists every currently installed plugin directory.
vim.api.nvim_create_user_command("PackRemove", function(opts)
    local name = vim.trim(opts.args)
    if name == "" then
        vim.notify("PackRemove: provide a plugin name", vim.log.levels.WARN)
        return
    end
    local path = pack_root .. "/" .. name
    if vim.fn.isdirectory(path) == 0 then
        vim.notify("PackRemove: '" .. name .. "' not found in pack opt/", vim.log.levels.WARN)
        return
    end
    vim.fn.delete(path, "rf")
    vim.notify("PackRemove: removed '" .. name .. "'", vim.log.levels.INFO)
end, {
    nargs = 1,
    desc  = "Remove a specific plugin from disk by name",
    complete = function(lead)
        local matches = {}
        for _, name in ipairs(installed_names()) do
            if name:find(lead, 1, true) == 1 then
                table.insert(matches, name)
            end
        end
        return matches
    end,
})


vim.api.nvim_create_user_command("PackUpdate", function()
    vim.notify("vim.pack: updating all plugins…", vim.log.levels.INFO)
    vim.pack.update()
end, { desc = "Update all vim.pack plugins" })

-- <leader>l  – list installed plugins in a float
vim.keymap.set("n", "<leader>l", function()
    local names = installed_names()
    local lines = {}
    for _, name in ipairs(names) do
        table.insert(lines, string.format("%-40s  %s", name, pack_root .. "/" .. name))
    end
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
        row       = math.floor((vim.o.lines   - height) / 2),
        col       = math.floor((vim.o.columns - width)  / 2),
        style     = "minimal",
        border    = "rounded",
        title     = " Installed Packs (" .. #names .. ") ",
        title_pos = "center",
    })
    vim.keymap.set("n", "q",     "<cmd>close<cr>", { buffer = buf, silent = true })
    vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
end, { desc = "List installed packs" })
