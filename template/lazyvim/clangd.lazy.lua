local lspconfig = require("lspconfig")

return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                clangd = {
                    cmd = {
                        "docker exec -i container_name clangd "
                            .. "--background-index "
                            .. "-j=8"
                            .. "--clang-tidy "
                            .. "--header-insertion=never "
                            .. "--pch-storage=memory" -- disk 废磁盘，memory 废内存
                            .. "--compile-commands-dir=build",
                        -- .. "--path-mapping=/path/on/host=/path/on/container" -- 容器路径映射
                        -- .. "--malloc-trim=false" -- clangd 默认会周期性调用 malloc_trim 归还内存给系统。关掉以后内存占用会一直高，但避免频繁释放/重新申请，性能更稳。
                        -- .. "--all-scopes-completion" -- 跨作用域都给你列出来（更多结果、更慢、更耗内存，但更“全”）
                        -- .. "--limit-results=0" -- 补全结果不做数量限制
                    },
                    InlayHints = {
                        Designators = true,
                        Enabled = true,
                        ParameterNames = true,
                        DeducedTypes = true,
                    },
                    fallbackFlags = { "-std=c++20" },
                    keys = {
                        { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
                    },
                    root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git", ".clangd"),
                },
            },
        },
    },
}
