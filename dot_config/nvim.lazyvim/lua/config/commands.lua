-- LuaSnip
vim.api.nvim_create_user_command("LuaSnipEdit", function()
    require("luasnip.loaders").edit_snippet_files()
end, { nargs = 0, desc = "Edit LuaSnip of current filetype" })

-- Formatting
vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format({ async = true, lsp_fallback = true, range = range })
end, { range = true })

vim.api.nvim_create_user_command("ChangeProjectRoot", function()
    vim.cmd("lcd " .. LazyVim.root())
end, { nargs = 0, desc = "Change project root to LazyVim.root()" })

-- Detach from remote (close the last UI)
-- drop in replacement for :detach on windows
-- on unix we can use <C-z> or :detach
-- ref: https://github.com/neovim/neovim/issues/23093#issuecomment-1509831000
-- tracking: https://github.com/neovim/neovim/pull/30319
vim.api.nvim_create_user_command("Detach", function(args)
    if vim.fn.has("win32") == 1 then
        local uis = vim.api.nvim_list_uis()
        if #uis > 0 then
            local chan_id = uis[#uis].chan
            vim.fn.chanclose(chan_id)
        end
    else
        vim.cmd("detach")
    end
end, {nargs = 0, desc = "Detach from remote"})

vim.api.nvim_create_user_command("SafeQuit", function()
    if vim.g.is_last_normal_window() then
        print("This is the last window, use :qa to quit")
    else
        vim.cmd("quit")
    end
end, {})

if vim.g.safequit then
    vim.cmd([[cnoreabbrev <expr> q getcmdtype() == ":" ? "SafeQuit" : "q"]])
end
