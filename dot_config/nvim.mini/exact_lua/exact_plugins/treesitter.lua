-- ~/.config/nvim.mini/lua/plugins/treesitter.lua
-- nvim-treesitter: parser install plus manual startup for highlight/indent/folds

require("pack").add("https://github.com/nvim-treesitter/nvim-treesitter")

local ok_ts, treesitter = pcall(require, "nvim-treesitter")
if not ok_ts then return end

local ok_lang, lang_registry = pcall(require, "lang")

local function disable_treesitter(buf)
    -- Keep heavy buffers simple: vimtex handles latex, snacks.nvim marks
    -- large files as `bigfile`, and diff windows should avoid parser work.
    local winid = vim.fn.bufwinid(buf)
    return vim.bo[buf].filetype == "latex"  -- vimtex will handle it
        or vim.bo[buf].filetype == "bigfile"
        or (winid ~= -1 and vim.wo[winid].diff)
end

-- Core parsers used regardless of LSP language toggles. Language-specific
-- parsers come from `lang/*.lua` through `lang.collect()`.
local ensure_installed = {
    "bash",
    "markdown",
    "markdown_inline",
    "vim",
    "vimdoc",
}

if ok_lang then
    local lang_specs = lang_registry.collect()
    vim.list_extend(ensure_installed, lang_specs.ensure_treesitter)
end

ensure_installed = vim.fn.uniq(vim.fn.sort(ensure_installed))

treesitter.setup()

local installed = {}
for _, lang in ipairs(treesitter.get_installed()) do
    installed[lang] = true
end

local missing = {}
for _, lang in ipairs(ensure_installed) do
    if not installed[lang] then
        table.insert(missing, lang)
    end
end

if #missing > 0 then
    treesitter.install(missing, { summary = true }):wait(300000)
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("nvim_mini_treesitter", { clear = true }),
    callback = function(ev)
        if disable_treesitter(ev.buf) then return end
        if not pcall(vim.treesitter.start, ev.buf) then return end

        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})
