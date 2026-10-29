-- Chinese word motions for prose. Register/install at startup, but keep Python
-- and jieba off runtimepath until the first motion in an eligible buffer.
local local_cfg = require("local")
if not (local_cfg.lang or {}).rime then return end

require("pack").add({
    {
        src = "https://github.com/kkew3/jieba.vim",
        version = "=1.0.5",
        build = "bash ./build.sh",
        defer = true,
    },
    -- jieba's operator mappings use repeat#set; without this, dw followed by
    -- dot repeats the underlying edit rather than the Chinese word operation.
    { src = "https://github.com/tpope/vim-repeat", defer = true },
})

local loaded, failed = false, false
local function load()
    if loaded then return true end
    if failed then return false end
    -- has('python3') itself can start provider detection; do not run it during
    -- startup. Missing Python must leave normal Vim motions usable.
    vim.g.jieba_vim_lazy = 1
    vim.g.jieba_vim_keymap = 0
    local ok, err = pcall(function()
        if vim.fn.has("python3") ~= 1 then error("Python3 provider unavailable") end
        vim.cmd.packadd("vim-repeat")
        vim.cmd.packadd("jieba.vim")
        assert(vim.fn.maparg("<Plug>(Jieba_w)", "n") ~= "", "jieba backend failed to load")
    end)
    if not ok then
        failed = true
        vim.schedule(function() vim.notify("jieba: " .. tostring(err), vim.log.levels.WARN) end)
        return false
    end
    loaded = true
    return true
end

local filetypes = { markdown = true, quarto = true, org = true, norg = true, text = true }
local motions = { "w", "W", "e", "E", "b", "B", "ge", "gE" }
local function attach(bufnr)
    if not filetypes[vim.bo[bufnr].filetype] and not vim.b[bufnr].jieba_mapped then return end
    -- Remove only our mappings when a prose buffer changes to a code filetype.
    for _, mode in ipairs({ "n", "x", "o" }) do
        for _, key in ipairs(motions) do
            if filetypes[vim.bo[bufnr].filetype] then
                vim.keymap.set(mode, key, function()
                    if load() then return "<Plug>(Jieba_" .. key .. ")" end
                    return key
                end, { buffer = bufnr, expr = true, silent = true, desc = "Jieba word motion " .. key })
            else
                local mapping = vim.api.nvim_buf_call(bufnr, function() return vim.fn.maparg(key, mode, false, true) end)
                if mapping.desc == "Jieba word motion " .. key then pcall(vim.keymap.del, mode, key, { buffer = bufnr }) end
            end
        end
    end
    vim.b[bufnr].jieba_mapped = filetypes[vim.bo[bufnr].filetype] == true
end
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("nvim_mini_jieba", { clear = true }),
    callback = function(ev) attach(ev.buf) end,
})
for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and filetypes[vim.bo[bufnr].filetype] then attach(bufnr) end
end
