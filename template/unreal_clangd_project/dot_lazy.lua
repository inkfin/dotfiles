return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				clangd = {
					-- root_dir = vim.cmd("pwd"),
					cmd = {
						"C:\\Program Files\\LLVM\\bin\\clangd.exe",
						"--background-index",
						"--clang-tidy",
						"--header-insertion=iwyu",
						"--completion-style=detailed",
						"--function-arg-placeholders",
						"--fallback-style=llvm",
					},
				},
			},
		},
	},
	{
		"nvim-telescope/telescope.nvim",
		opts = {
			defaults = {
				file_ignore_patterns = {
                    ".svn",
					".cache",
                    "build",
                    "Build",
                    "Binaries",
                    "Intermediate",
                    "DerivedDataCache",
                    "compile_commands.json",
				},
			},
		},
	},
}
