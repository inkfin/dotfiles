-- ~/.config/nvim.mini/lua/plugins/treesitter.lua
-- nvim-treesitter: syntax highlighting and folding

require("pack").add("https://github.com/nvim-treesitter/nvim-treesitter")

local ok, configs = pcall(require, "nvim-treesitter.configs")
if not ok then return end

local ok_lang, lang_registry = pcall(require, "lang")

local function disable_treesitter(_, buf)
    -- Keep heavy buffers simple: vimtex handles latex, snacks.nvim marks
    -- large files as `bigfile`, and diff windows should avoid parser work.
    local winid = vim.fn.bufwinid(buf)
    return vim.bo[buf].filetype == "latex"  -- vimtex will handle it
        or vim.bo[buf].filetype == "bigfile"
        or (winid ~= -1 and vim.wo[winid].diff)
end

-- Core parsers used regardless of LSP language toggles. Language-specific
-- parsers come from `lang/*.lua` through `lang.collect(enabled)`.
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

configs.setup({
    -- Install core parsers plus any parser declared by enabled language specs.
    ensure_installed = ensure_installed,
    highlight = {
        enable   = true,
        disable  = disable_treesitter,
    },
    indent    = {
        enable = true,
        disable = disable_treesitter,
    },
})
