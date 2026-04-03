-- ~/.config/nvim.mini/init.lua
-- Minimal Neovim config using built-in vim.pack (Neovim 0.12+)
-- Launch with: NVIM_APPNAME=nvim.mini nvim

-- Set leader keys before anything else
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Install plugins via vim.pack
-- On first run this will download plugins; subsequent runs load from cache.
vim.pack.add({
    "https://github.com/echasnovski/mini.nvim",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/folke/flash.nvim",
    "https://github.com/jake-stewart/multicursor.nvim",
    "https://github.com/mbbill/undotree",
    "https://github.com/MagicDuck/grug-far.nvim",
    -- Neo-tree
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/nvim-neo-tree/neo-tree.nvim",
    "https://github.com/s1n7ax/nvim-window-picker",
    -- Telescope
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/nvim-telescope/telescope.nvim",
    "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
    "https://github.com/jvgrootveld/telescope-zoxide",
    -- LSP & completion
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/williamboman/mason.nvim",
    "https://github.com/williamboman/mason-lspconfig.nvim",
    { src = "https://github.com/Saghen/blink.cmp", version = vim.version.range(">=1") },
    -- Colorscheme
    "https://github.com/folke/tokyonight.nvim",
    -- Terminal
    "https://github.com/akinsho/toggleterm.nvim",
    -- Bufferline
    "https://github.com/akinsho/bufferline.nvim",
})

-- Build telescope-fzf-native after install/update
vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        if ev.data.kind == "delete" then return end
        local name = ev.data.spec and ev.data.spec.name or ""
        if name == "telescope-fzf-native.nvim" and vim.fn.executable("make") == 1 then
            vim.notify("telescope-fzf-native: building…", vim.log.levels.INFO)
            vim.system({ "make" }, { cwd = ev.data.path }, function(result)
                if result.code == 0 then
                    vim.notify("telescope-fzf-native: build succeeded", vim.log.levels.INFO)
                else
                    vim.notify("telescope-fzf-native: build FAILED\n" .. (result.stderr or ""), vim.log.levels.ERROR)
                end
            end)
        end
    end,
})

-- Load config modules
require("options")
require("autocmds")
require("plugins.mini")
require("plugins.treesitter")
require("plugins.flash")
require("plugins.multicursor")
require("plugins.undotree")
require("plugins.grug-far")
require("plugins.neo-tree")
require("plugins.telescope")
require("plugins.bufferline")
require("plugins.lsp")
require("plugins.blink")
require("plugins.colorscheme")
require("plugins.pack")
require("plugins.terminal")
-- keymaps last so all plugins are available
require("keymaps")
