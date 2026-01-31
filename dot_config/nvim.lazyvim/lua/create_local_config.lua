-- local_config.lua
-- machine specific configuration

--------------------------
-- Plugins disable list --

_G.disable_plugins = {

    --- extensions
    firenvim = true,
    sonarlint = true,
    flash = true,
    org = true,
    notebook = true,
    quarto = true,

    --- languages
    --cpp = true,
    --cmake = true,
    --python = true,
    --rust = true,
    typescript = true,
    go = true,
    -- shaders
    glsl = true,
    wgsl = true,
    -- typesets
    typst = true,
    tex = true,

    --- debugging
    --dap = true
    --overseer = true,

    --- AI
    copilot = true,
    harper = true,

    --- input method
    rime = true,
    --im_select = true,

    --- UI
    --noise = true, -- input command
    --notify = true, -- notification

    --wakatime = true,
    image = true,
}

-- slow down the initialization process
--vim.g.potato_computer = true

--------------------------
