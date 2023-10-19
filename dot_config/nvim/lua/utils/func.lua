---Change tab width
---@param width number
vim.g.settab = function(width)
    vim.opt.tabstop = width
    vim.opt.shiftwidth = width
    vim.opt.softtabstop = width
end

vim.g.file_exists = function(name)
    local f = io.open(name, "r")
    return f ~= nil and io.close(f)
end

---Convert a snake_case string to camelCase
---@param str string?
---@return string?
local function snake_to_camel(str)
    if not str then
        return nil
    end
    return (str:gsub("^%l", string.upper):gsub("_%l", string.upper):gsub("_", ""))
end

vim.g.snake_to_camel = snake_to_camel

---Convert a camelCase string to snake_case
---@param str string
---@return string|nil
local function camel_to_snake(str)
    if not str then
        return nil
    end
    return (str:gsub("%u", "_%1"):gsub("^_", ""):lower())
end

vim.g.camel_to_snake = camel_to_snake

local function tprint(tbl, indent)
    if not indent then
        indent = 0
    end
    local toprint = string.rep(" ", indent) .. "{\r\n"
    indent = indent + 2
    for k, v in pairs(tbl) do
        toprint = toprint .. string.rep(" ", indent)
        if type(k) == "number" then
            toprint = toprint .. "[" .. k .. "] = "
        elseif type(k) == "string" then
            toprint = toprint .. k .. "= "
        end
        if type(v) == "number" then
            toprint = toprint .. v .. ",\r\n"
        elseif type(v) == "string" then
            toprint = toprint .. '"' .. v .. '",\r\n'
        elseif type(v) == "table" then
            toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
        else
            toprint = toprint .. '"' .. tostring(v) .. '",\r\n'
        end
    end
    toprint = toprint .. string.rep(" ", indent - 2) .. "}"
    return toprint
end

vim.g.tprint = tprint

-- typewriter mode
vim.g.toggle_typewriter_mode = function()
    if vim.wo.scrolloff <= 5 then
        vim.wo.scrolloff = 999
    else
        vim.wo.scrolloff = 5
    end
end

-------------------------------------------------------------------
-- Quickly Run
-------------------------------------------------------------------

vim.g.compile_run = function()
    vim.fn.execute("w")
    if vim.bo.filetype == "c" then
        vim.cmd([[
            " windows fix: can't execute file without '.exe' postfix
            if has("win32")
                exec "!clang % -o %<.exe"
                exec "!time %<.exe"
            else
                exec "!clang % -o %<"
                exec "!time %<"
            endif
        ]])
    elseif vim.bo.filetype == "cpp" then
        vim.cmd([[
            set splitbelow
            :sp
            :res +10
            if has("win32")
                exec "!clang++ -std=c++17 % -Wall -o %<.exe"
                :term time %<.exe
            else
                exec "!clang++ -std=c++17 % -Wall -o %<"
                :term time %<
            endif
        ]])
    elseif vim.bo.filetype == "rust" then
        vim.cmd([[
            set splitbelow
            exec "!rustc %"
            :sp
            :res +5
            if has("win32")
                :term time %<.exe
            else
                :term time %<
            endif
        ]])
    elseif vim.bo.filetype == "java" then
        vim.cmd([[
            exec "!javac %"
            if has("win32")
                exec "!time java %<.exe"
            else
                exec "!time java %<"
            endif
        ]])
    elseif vim.bo.filetype == "sh" then
        vim.cmd([[
            :!time bash %
        ]])
    elseif vim.bo.filetype == "python" then
        vim.cmd([[
            set splitbelow
            :sp
            :term python3 %
        ]])
    elseif vim.bo.filetype == "html" then
        vim.cmd([[
            silent! exec "!".g:mkdp_browser." % &"
        ]])
    elseif vim.bo.filetype == "markdown" then
        vim.cmd([[
            :MarkdownPreviewToggle
        ]])
    elseif vim.bo.filetype == "tex" then
        vim.cmd([[
            :echo "Latex not surpport yet"
        ]])
    elseif vim.bo.filetype == "javascript" then
        vim.cmd([[
            set splitbelow
            :sp
            :term export DEBUG="INFO,ERROR,WARNING"; node --trace-warnings .
        ]])
    elseif vim.bo.filetype == "go" then
        vim.cmd([[
            set splitbelow
            :sp
            :term go run .
        ]])
    end
end

-------------------------------------------------------------------
-- CMake
-------------------------------------------------------------------

---Build cmake project according to getcwd() and user input
---referenced from https://github.com/mfussenegger/nvim-dap/wiki/Cookbook#making-debugging-net-easier
vim.g.cmake_build_project = function()
    vim.g.read_nvim_custom_config() -- reload config
    local default_path = vim.fn.getcwd() .. "/"
    if vim.g["cmake_last_proj_path"] ~= nil then
        default_path = vim.g["cmake_last_proj_path"]
    end
    ---@diagnostic disable-next-line: redundant-parameter
    local path = vim.fn.input("Path to your CMakeLists.txt ", default_path, "file")
    vim.g["cmake_last_proj_path"] = path
    -- vim.g.write_nvim_custom_config() -- update config
    local cmake_args = " -Bbuild-debug -GNinja -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_BUILD_TYPE=Debug "
    local cmd0 = "cmake " .. path .. cmake_args -- .. " > /dev/null"
    local cmd1 = "cmake --build build-debug" -- .. " > /dev/null"
    print("\n(0/2)Cmd to execute: " .. cmd0)
    local f = os.execute(cmd0)
    if f == 0 then
        print("\nGenerate build: ✔️ ")

        print("\n(1/2)Cmd to execute: " .. cmd1)

        f = os.execute(cmd1)
        if f == 0 then
            print("\n(2/2)Build: ✔️ ")
        else
            print("\nBuild: ❌ (code: " .. f .. ")")
            return false
        end
    else
        print("\nGenerate build: ❌ (code: " .. f .. ")")
        return false
    end

    -- local _cmd = "cp " .. path .. "build-debug/compile_commands.json " .. path
    -- print(_cmd)
    -- f = os.execute(_cmd)
    -- if f == 0 then
    --     print("\n'compile_command.json' copied to rootdir")
    -- else
    --     print("\nCan't copy 'compile_command.json' to rootdir!\n(code: " .. f .. ")")
    -- end
    return true
end

---Return cmake project executable file path according to getcwd() and user input
vim.g.cmake_get_exec_path = function()
    local request = function()
        local path = ""
        if vim.g["cmake_last_exec_path"] ~= nil then
            path = vim.g["cmake_last_exec_path"]
        else
            path = vim.fn.getcwd() .. "/build-debug/main"
        end
        ---@diagnostic disable-next-line: redundant-parameter
        return vim.fn.input("Path to executable ", path, "file")
    end

    -- reload config
    vim.g.read_nvim_custom_config()
    if vim.g["cmake_last_exec_path"] == nil then
        vim.g["cmake_last_exec_path"] = request()
    else
        local choice = vim.fn.confirm(
            "Do you want to change the path to executable?\n" .. vim.g["cmake_last_exec_path"],
            "&yes\n&no",
            2
        )
        if choice == 1 then
            vim.g["cmake_last_exec_path"] = request()
        elseif choice == 0 then
            return nil
        end
    end

    -- vim.g.write_nvim_custom_config() -- update config

    return vim.g["cmake_last_exec_path"]
end

-- change cwd to binary folder
vim.g.cmake_get_exec_directory = function()
    -- local path = vim.fn.fnamemodify(vim.g["cmake_last_exec_path"], ":h")

    -- Use pattern to match the folder path
    local pattern = "(.-)[\\/]([^\\/]-%.([^\\/%.]-))$"
    local path, _, _ = string.match(vim.g["cmake_last_exec_path"], pattern)

    print("Program executed in: " .. path)
    return path
    -- return "${workspaceFolder}"
end

vim.g.nvim_config_variables = {
    "cmake_last_exec_path",
    "cmake_last_proj_path",
}

-- tool function to load nvim_config.toml
vim.g.read_nvim_custom_config = function()
    local root_dir = vim.fn.getcwd()
    local out = nil
    local toml = require("utils/toml")
    local f, err = io.open(root_dir .. "/.vscode/nvim_config.toml", "r")
    if
        vim.fn.isdirectory(root_dir .. "/.vscode") == 1
        and vim.fn.filereadable(root_dir .. "/.vscode/nvim_config.toml") == 1
    then
        if f ~= nil then
            out = toml.parse(f:read("*all"))
            for key, value in pairs(out["variables"]) do
                vim.g[key] = value
            end
            f:close()
        end
    else
        print("Didn't find nvim_config.toml, error: " .. err)
    end
    return out
end

-- tool function to write variables in g:nvim_config_variables to nvim_config.toml
vim.g.write_nvim_custom_config = function()
    local root_dir = vim.fn.getcwd()
    -- lua check if .vscode folder exists
    if vim.fn.isdirectory(root_dir .. "/.vscode") == 0 then
        vim.fn.mkdir(root_dir .. "/.vscode")
    end
    local toml = require("utils/toml")
    local f, error = io.open(".vscode/nvim_config.toml", "w+")
    if f ~= nil then
        local nvim_config = {}
        for _, key in ipairs(vim.g.nvim_config_variables) do
            nvim_config[key] = vim.g[key]
        end
        local out_config = { variables = nvim_config }
        f:write(toml.encode(out_config))
        print("Write nvim custom config to `.vscode/nvim_config.toml`.")
        f:close()
    else
        print("Can't open nvim_config.toml, error message: " .. error)
    end
end
