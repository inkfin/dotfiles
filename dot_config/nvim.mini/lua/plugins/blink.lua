-- ~/.config/nvim.mini/lua/plugins/blink.lua
-- Saghen/blink.cmp: fast LSP-based completion

local ok, blink = pcall(require, "blink.cmp")
if not ok then return end

blink.setup({
    --------------------------
    -- Keymap preset
    -- "default" gives sensible bindings; we override a few below.
    --------------------------
    keymap = {
        preset = "default",

        -- Trigger completion manually
        ["<C-Space>"] = { "show", "fallback" },
        ["<C-\\>"]    = { "show", "fallback" },

        -- Scroll docs
        ["<C-u>"] = { "scroll_documentation_up",   "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },

        -- Abort
        ["<C-e>"] = { "hide", "fallback" },

        -- Confirm (replace word, select first if nothing selected)
        ["<CR>"]  = { "accept", "fallback" },

        -- Navigate items + jump through snippet tabstops
        ["<Tab>"]   = { "select_next", "snippet_forward",  "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },

        -- Arrow keys navigate items too
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
    },

    --------------------------
    -- Completion behaviour
    --------------------------
    completion = {
        -- Don't pre-select first item (must explicitly confirm)
        list = {
            selection = {
                preselect = false,
                auto_insert = true,
            },
        },
        -- Show documentation popup alongside the menu
        documentation = {
            auto_show       = true,
            auto_show_delay_ms = 100,
            window = { border = "rounded" },
        },
        menu = {
            border = "rounded",
        },
    },

    --------------------------
    -- Sources
    --------------------------
    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        -- Optional: per-filetype overrides
        -- per_filetype = {
        --     markdown = { "lsp", "path", "buffer" },
        -- },
    },

    --------------------------
    -- Snippets: use mini.snippets if available, else built-in
    --------------------------
    snippets = { preset = "default" },

    --------------------------
    -- Fuzzy matching
    --------------------------
    fuzzy = {
        -- Force prebuilt binary download even when not exactly on a release tag
        prebuilt_binaries = {
            force_version = "v1.*",
        },
    },

    --------------------------
    -- Appearance
    --------------------------
    appearance = {
        -- Use mini.icons if loaded, else nerd-font glyphs
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
    },

    --------------------------
    -- Signature help (shows function signature while typing args)
    --------------------------
    signature = {
        enabled = true,
        window  = { border = "rounded" },
    },
})
