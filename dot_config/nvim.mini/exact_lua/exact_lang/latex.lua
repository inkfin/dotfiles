-- ~/.config/nvim.mini/lua/lang/latex.lua
-- LaTeX support via vimtex + img-clip + texlab LSP
--
-- Default keymaps provided by vimtex (localleader = \):
--   dse / dsc / dsm  — delete surrounding env / cmd / math
--   cse / csc / csm  — change surrounding env / cmd / math
--   tse / tsd        — toggle surrounding env / delimiter modifier
--   <F7>             — create cmd in-place (insert)
--   ]]               — insert close delimiter (insert)

require("pack").add({
    "https://github.com/lervag/vimtex",
    "https://github.com/HakonHarnes/img-clip.nvim",
})

--------------------------
-- vimtex
--------------------------
vim.g.tex_flavor                   = "latex"
vim.g.vimtex_compiler_progname     = "nvr"   -- pip install neovim-remote
vim.g.vimtex_imaps_enabled         = 0       -- disable vimtex insert-mode maps (use blink instead)
vim.g.vimtex_quickfix_mode         = 0       -- don't auto-open quickfix
vim.g.vimtex_quickfix_method       =
    vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"
vim.g.vimtex_quickfix_ignore_filters = {
    "does not contain requested Script",
    "Overfull",
    "Underfull",
}

vim.g.vimtex_compiler_latexmk_engines = {
    ["_"]                    = "-pdf",
    ["pdfdvi"]               = "-pdfdvi",
    ["pdfps"]                = "-pdfps",
    ["pdflatex"]             = "-pdf",
    ["luatex"]               = "-lualatex",
    ["lualatex"]             = "-lualatex",
    ["xelatex"]              = "-xelatex",
    ["context (pdftex)"]     = "-pdf -pdflatex=texexec",
    ["context (luatex)"]     = "-pdf -pdflatex=context",
    ["context (xetex)"]      = "-pdf -pdflatex='texexec --xtx'",
}

-- PDF viewer
if vim.fn.has("mac") == 1 then
    vim.g.vimtex_view_method        = "skim"
    vim.g.vimtex_view_skim_sync     = 1
    vim.g.vimtex_view_skim_activate = 1
    vim.g.vimtex_view_skim_no_select   = 1
    vim.g.vimtex_view_skim_reading_bar = 1
elseif vim.fn.has("win32") == 1 then
    vim.g.vimtex_view_general_viewer  = "SumatraPDF"
    vim.g.vimtex_view_general_options =
        "-reuse-instance -forward-search @tex @line @pdf"
        .. ' -inverse-search "wt -w 0 \\"\\"\\ nvim --headless -c \\"VimtexInverseSearch %l \'%f\'\\""'
end

--------------------------
-- Autocommands (tex / bib buffers)
--------------------------
local augroup = vim.api.nvim_create_augroup("nvim_mini_latex", { clear = true })

-- conceal level for nicer rendering
vim.api.nvim_create_autocmd("FileType", {
    group   = augroup,
    pattern = { "tex", "bib" },
    callback = function()
        vim.wo.conceallevel = 2
    end,
})

-- Refocus Neovim after forward/reverse search
local function tex_focus_vim()
    if vim.fn.has("mac") == 1 then
        if vim.g.neovide then
            vim.cmd("silent !open -a Neovide")
        else
            vim.cmd("silent !open -a iTerm")
        end
    elseif vim.fn.has("win32") == 1 then
        if vim.g.neovide then
            vim.cmd("silent !Show-Window Neovide")
        else
            vim.cmd("silent !Show-Window WindowsTerminal")
        end
    end
    vim.cmd("redraw!")
end

vim.api.nvim_create_autocmd("User", {
    group   = augroup,
    pattern = { "VimtexEventView", "VimtexEventViewReverse" },
    callback = tex_focus_vim,
})

-- Keymaps + which-key group labels (buffer-local, tex only)
vim.api.nvim_create_autocmd("FileType", {
    group   = augroup,
    pattern = "tex",
    callback = function()
        local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs,
                { buffer = true, silent = true, desc = desc })
        end
        local xmap = function(lhs, rhs, desc)
            vim.keymap.set({ "x", "o" }, lhs, rhs,
                { buffer = true, silent = true, desc = desc })
        end

        -- Top-level actions
        map("<localleader>c", "<Cmd>write<CR><Cmd>VimtexCompile<CR>", "Compile")
        map("<localleader>f", "<Cmd>VimtexView<CR>",                  "Forward search (PDF sync)")
        map("<localleader>e", "<Plug>(vimtex-errors)",                 "Show errors")
        map("<localleader>r", "<Plug>(vimtex-reload)",                 "Reload")
        map("<localleader>t", "<Plug>(vimtex-toc-open)",               "Open TOC")
        map("<localleader>w", "<Cmd>VimtexCountWords<CR>",             "Count words")
        map("<localleader>i", "<Plug>(vimtex-imaps-list)",             "Show imap list")
        map("<localleader>z", "<Plug>(vimtex-clean)",                  "Clean auxiliary files")
        map("<localleader>Z", "<Plug>(vimtex-clean-full)",             "Clean all outputs")

        -- +open group
        map("<localleader>oi", "<Plug>(vimtex-info)",         "info")
        map("<localleader>oI", "<Plug>(vimtex-info-full)",    "info-full")
        map("<localleader>ot", "<Plug>(vimtex-toc-toggle)",   "toggle TOC")
        map("<localleader>os", "<Plug>(vimtex-status)",       "status")
        map("<localleader>oS", "<Plug>(vimtex-status-full)",  "status-full")

        -- +plugin group
        map("<localleader>pk", "<Plug>(vimtex-stop)",     "Stop VimTeX")
        map("<localleader>pK", "<Plug>(vimtex-stop-all)", "Stop VimTeX (all)")

        -- docs
        map("<localleader>h", "<Plug>(vimtex-doc-package)", "Package docs")

        -- surround (math)
        map("dsm", "<Plug>(vimtex-env-delete-math)", "Delete surr math")
        map("csm", "<Plug>(vimtex-cmd-change-math)", "Change surr math")

        -- text objects
        xmap("ii", "<Plug>(vimtex-im)",  "inner item")
        xmap("ai", "<Plug>(vimtex-am)",  "around item")
        xmap("im", "<Plug>(vimtex-i$)",  "inner inline math")
        xmap("am", "<Plug>(vimtex-a$)",  "around inline math")

        -- which-key group labels
        local ok, wk = pcall(require, "which-key")
        if ok then
            wk.add({
                buffer = true,
                { "<localleader>o", group = "open"   },
                { "<localleader>p", group = "plugin" },
            })
        end
    end,
})

--------------------------
-- img-clip (paste images into LaTeX)
--------------------------
local ok_clip, img_clip = pcall(require, "img-clip")
if ok_clip then
    img_clip.setup({
        file_types = {
            tex = {
                template = [[
\begin{figure}[h]
  \centering
  \includegraphics[width=0.8\textwidth]{$FILE_PATH}
  \caption{$CURSOR}
  \label{fig:$LABEL}
\end{figure}
                ]],
            },
        },
    })
end

local M = {
    mason_lspconfig = { "texlab" },
}

function M.setup()
    --------------------------
    -- texlab LSP
    --------------------------
    local ok_lsp, lsp_util = pcall(require, "lsp_util")
    if ok_lsp then
        lsp_util.setup("texlab", {})
    end
end

return M
