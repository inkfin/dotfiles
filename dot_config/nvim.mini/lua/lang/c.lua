-- ~/.config/nvim.mini/lua/lang/c.lua
-- C / C++ / CMake LSP configuration
-- Servers: clangd, neocmake

local lsp = require("lsp_util")

--------------------------
-- clangd (C / C++ / ObjC)
--------------------------
lsp.setup("clangd", {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",        -- include-what-you-use hints
        "--completion-style=detailed",    -- show full signatures in completion
        "--function-arg-placeholders",    -- insert snippet placeholders for args
        "--fallback-style=llvm",
    },
    -- clangd only supports utf-16 offset encoding; avoids "multiple clients
    -- with different offset encodings" warning when clangd and another server
    -- attach to the same buffer.
    capabilities = (function()
        local caps = lsp.capabilities()
        caps.offsetEncoding = { "utf-16" }
        return caps
    end)(),
    init_options = {
        usePlaceholders    = true,
        completeUnimported = true,
        clangdFileStatus   = true,   -- show file status in statusline
    },
    root_markers = {
        "compile_commands.json",
        "compile_flags.txt",
        ".clangd",
        ".clang-tidy",
        ".clang-format",
        "configure.ac",
        "meson.build",
        "build.ninja",
        "CMakeLists.txt",
        "Makefile",
        ".git",
    },
    -- C/C++ inlay hints via clangd (available natively in Neovim 0.10+)
    settings = {
        clangd = {
            InlayHints = {
                Designators    = true,
                Enabled        = true,
                ParameterNames = true,
                DeducedTypes   = true,
            },
            fallbackFlags = { "-std=c++20" },
        },
    },
})

-- Switch between source / header  (<leader>ch)
-- Uses the LSP extension directly — no clangd_extensions plugin needed.
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("nvim_mini_clangd", { clear = true }),
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client or client.name ~= "clangd" then return end
        vim.keymap.set("n", "<leader>ch",
            "<cmd>LspClangdSwitchSourceHeader<cr>",
            { buffer = ev.buf, silent = true, desc = "Switch Source/Header (C/C++)" })
    end,
})

--------------------------
-- neocmake (CMakeLists.txt)
--------------------------
lsp.setup("neocmake", {
    capabilities = (function()
        local caps = lsp.capabilities()
        -- neocmake needs workspace file-watcher and snippet support
        caps.workspace = vim.tbl_deep_extend("force", caps.workspace or {}, {
            didChangeWatchedFiles = {
                dynamicRegistration      = true,
                relative_pattern_support = true,
            },
        })
        caps.textDocument = vim.tbl_deep_extend("force", caps.textDocument or {}, {
            completion = {
                completionItem = { snippetSupport = true },
            },
        })
        return caps
    end)(),
})
