local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local builtin = require("telescope.builtin")

-- 自定义函数：列出光标下符号的 ctags 引用
---@param use_cword boolean 是否使用光标下的单词
local function ctags_refs(use_cword)
    local symbol

    if use_cword then
        symbol = vim.fn.expand("<cword>")
    else
        symbol = vim.fn.input("Symbol: ")
        if symbol == "" then
            print("No symbol provided")
            return
        end
    end

    local tagsfile = "tags"
    if vim.fn.filereadable(tagsfile) == 0 then
        print("No tags file found")
        return
    end

    -- grep tags 文件，找出 symbol 的引用 (kind:r)
    local results = {}
    for line in io.lines(tagsfile) do
        if line:match("^" .. symbol .. "\t") and line:match("kind:r") then
            table.insert(results, line)
        end
    end

    if #results == 0 then
        print("No references found for " .. symbol)
        return
    end

    -- 调用 Telescope 展示结果
    pickers
        .new({}, {
            prompt_title = "CTags Refs for " .. symbol,
            finder = finders.new_table({
                results = results,
            }),
            sorter = conf.generic_sorter({}),
        })
        :find()
end

-- 注册命令

vim.api.nvim_create_user_command("CtagsRefs", function()
    ctags_refs(true)
end, {})

vim.api.nvim_create_user_command("CtagsRefsInput", function()
    ctags_refs(false)
end, {})

-- vim.keymap.set("n", "<leader>ft", ":CtagsRefs<CR>", { noremap = true, silent = true })
-- vim.keymap.set("n", "<leader>fT", ":CtagsRefsInput<CR>", { noremap = true, silent = true })

return {
    {
        "nvim-telescope/telescope.nvim",
        opts = {
            defaults = {
                layout_strategy = "flex", -- default horizontal
                layout_config = {
                    horizontal = {
                        preview_cutoff = 80,
                    },
                    vertical = {
                        preview_cutoff = 80,
                    },
                },
                file_ignore_patterns = {
                    ".git",
                    ".svn",
                    ".cache",
                    "node_modules",
                    "spell", -- nvim dictionaries
                    "elpa", -- emacs packages
                    ".cache",
                },
            },
        },
        keys = {
            { "<leader>ft", "<cmd>CtagsRefs<CR>", desc = "CTags Refs" },
            { "<leader>fT", "<cmd>CtagsRefsInput<CR>", desc = "CTags Refs Input" },
        },
    },
    {
        "jvgrootveld/telescope-zoxide",
        keys = {
            {
                "<leader>fz",
                function()
                    require("telescope").extensions.zoxide.list()
                end,
                desc = "Zoxide list",
            },
        },
        config = function()
            require("telescope").load_extension("zoxide")
        end,
    },
}
