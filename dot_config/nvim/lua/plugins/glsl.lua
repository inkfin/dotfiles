return {
    {
        "neovim/nvim-lspconfig",
        enabled = vim.fn.executable("glsl_analyzer") ~= 0,
        --- download glsl_analyzer from https://github.com/nolanderc/glsl_analyzer/releases/latest/
        ---@class PluginLspOpts
        opts = {
            ---@type lspconfig.options
            servers = {
                glsl_analyzer = {
                    cmd = { "glsl_analyzer" },
                    filetypes = {
                        "glsl",
                        "vert",
                        "tesc",
                        "tese",
                        "frag",
                        "geom",
                        "comp",
                    },
                    single_file_support = true,
                },
            },
        },
    },
}
