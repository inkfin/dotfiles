if _G.disable_plugins.notebook then
    return {}
end

-- stylua: ignore
-- vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, { pattern = {"*.ipynb"}, callback = function() vim.bo.filetype = "jupyter_notebook" end })

return {
    -- Better inline REPL for neovim
    -- https://github.com/benlubas/molten-nvim/blob/main/docs/Not-So-Quick-Start-Guide.md
    -- https://github.com/benlubas/molten-nvim/blob/main/docs/Notebook-Setup.md
    -- python requirements: `pip install pynvim jupyter_client`
    {
        "benlubas/molten-nvim",
        enabled = vim.fn.has("mac") == 1,
        ft = { "quarto", "markdown", "jupyter_notebook" },
        version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
        build = ":UpdateRemotePlugins",
        -- https://github.com/benlubas/molten-nvim?tab=readme-ov-file#configuration
        init = function()
            vim.g.molten_image_provider = "image.nvim"
            vim.g.molten_output_win_max_height = 20
            vim.g.molten_auto_open_output = false

            vim.g.molten_wrap_output = true
            vim.g.molten_virt_text_output = true
            vim.g.molten_virt_lines_off_by_1 = true
        end,
        -- stylua: ignore
        config = function()
            vim.keymap.set("n", "<localleader>mi", ":MoltenInit<CR>", { desc = "Molten Init", silent = true, buffer = true })
            vim.keymap.set("n", "<localleader>e", ":MoltenEvaluateOperator<CR>", { desc = "evaluate operator", silent = true, buffer = true })

            -- configure in quarto
            if vim.bo.ft ~= "quarto" then
            vim.keymap.set("n", "<localleader>rr", ":MoltenReevaluateCell<CR>", { desc = "re-eval cell", silent = true, buffer = true })
            vim.keymap.set("v", "<localleader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "execute visual selection", silent = true, buffer = true })
            vim.keymap.set("n", "<localleader>os", ":noautocmd MoltenEnterOutput<CR>", { desc = "show molten output window", silent = true, buffer = true })
            vim.keymap.set("n", "<localleader>oh", ":MoltenHideOutput<CR>", { desc = "hide molten output window", silent = true, buffer = true })
            vim.keymap.set("n", "<localleader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true, buffer = true })

            -- if you work with html outputs:
            vim.keymap.set("n", "<localleader>mx", ":MoltenOpenInBrowser<CR>", { desc = "open output in browser", silent = true, buffer = true })
            end

            local wk = require("which-key")
            wk.add({
                buffer = true,
                mode = { "n", "v" },
                { "<localleader>m", group = "molten" },
                { "<localleader>o", group = "output" },
            })
        end,
    },

    -- send code from python/r/qmd documets to a terminal or REPL
    -- like ipython, R, bash
    {
        "jpalardy/vim-slime",
        enabled = false,
        ft = "quarto",
        init = function()
            vim.b["quarto_is_python_chunk"] = false
            Quarto_is_in_python_chunk = function()
                require("otter.tools.functions").is_otter_language_context("python")
            end

            vim.cmd([[

            let g:slime_dispatch_ipython_pause = 100
            function SlimeOverride_EscapeText_quarto(text)
            call v:lua.Quarto_is_in_python_chunk()
            if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk && !(exists('b:quarto_is_r_mode') && b:quarto_is_r_mode)
            return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
            else
            if exists('b:quarto_is_r_mode') && b:quarto_is_r_mode && b:quarto_is_python_chunk
            return [a:text, "\n"]
            else
            return [a:text]
            end
            end
            endfunction

            ]])

            vim.g.slime_target = "neovim"
            vim.g.slime_no_mappings = true
            vim.g.slime_python_ipython = 1
        end,

        config = function()
            vim.g.slime_input_pid = false
            vim.g.slime_suggest_default = true
            vim.g.slime_menu_config = false
            vim.g.slime_neovim_ignore_unlisted = true

            local function mark_terminal()
                local job_id = vim.b.terminal_job_id
                vim.print("job_id: " .. job_id)
            end

            local function set_terminal()
                vim.fn.call("slime#config", {})
            end

            -- local function mark_terminal()
            --     vim.g.slime_last_channel = vim.b.terminal_job_id
            --     vim.print(vim.g.slime_last_channel)
            -- end

            -- local function set_terminal()
            --     vim.b.slime_config = { jobid = vim.g.slime_last_channel }
            -- end

            -- vim.b.slime_cell_delimiter = "# %%"

            require("which-key").add({
                { "<localleader>r", desc = "Quarto Run" },
                { "<localleader>t", desc = "Slime Terminal" },
                { "<localleader>tm", mark_terminal, desc = "slime mark terminal" },
                { "<localleader>ts", set_terminal, desc = "slime set terminal" },
            })
        end,
    },
}
