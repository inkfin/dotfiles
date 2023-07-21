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

---Build cmake project according to getcwd() and user input
---referenced from https://github.com/mfussenegger/nvim-dap/wiki/Cookbook#making-debugging-net-easier
local cmake_build_project = function()
    local default_path = vim.fn.getcwd() .. "/"
    if vim.g["cmake_last_proj_path"] ~= nil then
        default_path = vim.g["cmake_last_proj_path"]
    end
    ---@diagnostic disable-next-line: redundant-parameter
    local path = vim.fn.input("Path to your CMakeLists.txt ", default_path, "file")
    vim.g["cmake_last_proj_path"] = path
    local cmake_args = " -Bbuild-debug -GNinja -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_BUILD_TYPE=Debug "
    local cmd = "cmake " .. path .. cmake_args .. " > /dev/null && cmake --build build-debug" .. " > /dev/null"
    print("")
    print("Cmd to execute: " .. cmd)
    local f = os.execute(cmd)
    if f == 0 then
        print("\nBuild: ✔️ ")
    else
        print("\nBuild: ❌ (code: " .. f .. ")")
    end
end

vim.g.cmake_build_project = cmake_build_project

---Return cmake project executable file path according to getcwd() and user input
local cmake_get_exec_path = function()
    local request = function()
        ---@diagnostic disable-next-line: redundant-parameter
        return vim.fn.input("Path to executable ", vim.fn.getcwd() .. "/build-debug/main", "file")
    end

    if vim.g["cmake_last_exec_path"] == nil then
        vim.g["cmake_last_exec_path"] = request()
    else
        if
            vim.fn.confirm(
                "Do you want to change the path to executable?\n" .. vim.g["cmake_last_exec_path"],
                "&yes\n&no",
                2
            ) == 1
        then
            vim.g["cmake_last_exec_path"] = request()
        end
    end

    return vim.g["cmake_last_exec_path"]
end

vim.g.cmake_get_exec_path = cmake_get_exec_path
