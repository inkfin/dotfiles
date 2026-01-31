-- im_select
--
-- download im-select executable if don't exists
-- Windows:
--   curl -L https://github.com/daipeihust/im-select/raw/master/win/out/x86/im-select.exe -o $HOME\.local\bin\im-select.exe
-- MacOS (brew):
--   brew tap daipeihust/tap
--   brew install im-select
-- Linux:
--   curl -Ls https://raw.githubusercontent.com/daipeihust/im-select/master/install_mac.sh | sh

return {
    {
        "keaising/im-select.nvim",
        enabled = _G.disable_plugins.rime
            and not _G.disable_plugins.im_select
            and (vim.fn.executable("im-select") == 1 or (vim.fn.has("mac") == 1 and vim.fn.executable("macism"))),
        opts = {
            -- Async run `default_command` to switch IM or not
            async_switch_im = false,
        },
    },
}
