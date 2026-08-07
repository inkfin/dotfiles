-- ~/.config/nvim.mini/lua/plugins/treesitter.lua
-- nvim-treesitter: parser install plus manual startup for highlight/indent/folds

require("pack").add("https://github.com/nvim-treesitter/nvim-treesitter")

local ok_ts, treesitter = pcall(require, "nvim-treesitter")
if not ok_ts then return end

local ok_lang, lang_registry = pcall(require, "lang")
local treesitter_cli_version = "0.26.11"

local function ensure_treesitter_cli(done)
    if vim.fn.executable("tree-sitter") == 1 then done(true) return end

    local system = vim.uv.os_uname().sysname:lower()
    local machine = vim.uv.os_uname().machine:lower()
    local platform = system == "darwin" and "macos"
        or system:match("windows") and "windows"
        or system == "linux" and "linux"
    local arch = (machine == "arm64" or machine == "aarch64") and "arm64"
        or machine == "x86_64" and "x64"
    if not platform or not arch then
        vim.notify("Tree-sitter CLI: unsupported platform or architecture", vim.log.levels.WARN)
        done(false)
        return
    end

    local suffix = platform == "windows" and ".exe" or ""
    local bin_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "tree-sitter-cli")
    local bin = vim.fs.joinpath(bin_dir, "tree-sitter" .. suffix)
    local separator = platform == "windows" and ";" or ":"
    if vim.uv.fs_stat(bin) then
        vim.env.PATH = bin_dir .. separator .. (vim.env.PATH or "")
        done(true)
        return
    end

    local archive_ext = platform == "windows" and "zip" or "gz"
    local extractor = platform == "windows" and "tar" or "gzip"
    if vim.fn.executable("curl") ~= 1 or vim.fn.executable(extractor) ~= 1 then
        vim.notify("Tree-sitter CLI needs curl and " .. extractor .. " to bootstrap", vim.log.levels.WARN)
        done(false)
        return
    end

    local archive = vim.fs.joinpath(vim.fn.stdpath("cache"), "tree-sitter-cli." .. archive_ext)
    local artifact = "tree-sitter-cli-" .. platform .. "-" .. arch
    local url = string.format(
        "https://github.com/tree-sitter/tree-sitter/releases/download/v%s/%s.%s",
        treesitter_cli_version, artifact, archive_ext
    )
    vim.fn.mkdir(bin_dir, "p")

    vim.system({ "curl", "--fail", "--location", "--silent", "--show-error", url,
        "--output", archive }, function(result)
        if result.code ~= 0 then
            vim.notify("Tree-sitter CLI download failed: " .. (result.stderr or ""), vim.log.levels.WARN)
            done(false)
            return
        end

        local function finish(success, message)
            vim.fs.rm(archive)
            if not success then
                vim.notify(message, vim.log.levels.WARN)
                done(false)
                return
            end
            if platform ~= "windows" then vim.uv.fs_chmod(bin, 493) end
            vim.env.PATH = bin_dir .. separator .. (vim.env.PATH or "")
            done(true)
        end

        if platform == "windows" then
            vim.system({ "tar", "-xf", archive, "-C", bin_dir }, function(extract)
                finish(extract.code == 0 and vim.uv.fs_stat(bin) ~= nil,
                    "Tree-sitter CLI extraction failed: " .. (extract.stderr or ""))
            end)
        else
            vim.system({ "gzip", "-d", "-f", archive }, function(extract)
                if extract.code ~= 0 then
                    finish(false, "Tree-sitter CLI extraction failed: " .. (extract.stderr or ""))
                    return
                end
                vim.uv.fs_rename(archive:gsub("%.gz$", ""), bin, function(err)
                    finish(not err and vim.uv.fs_stat(bin) ~= nil,
                        "Tree-sitter CLI extraction failed: " .. (err or "unknown error"))
                end)
            end)
        end
    end)
end

local function disable_treesitter(buf)
    local winid = vim.fn.bufwinid(buf)
    return vim.bo[buf].filetype == "latex"
        or vim.bo[buf].filetype == "bigfile"
        or (winid ~= -1 and vim.wo[winid].diff)
end

local ensure_installed = {
    "bash", "markdown", "markdown_inline", "vim", "vimdoc",
    "commonlisp", "embedded_template", "fish", "json", "powershell", "yaml",
}
if ok_lang then
    vim.list_extend(ensure_installed, lang_registry.collect().ensure_treesitter)
end
ensure_installed = vim.fn.uniq(vim.fn.sort(ensure_installed))

treesitter.setup()
vim.treesitter.language.register("embedded_template", "template")

local installed = {}
for _, lang in ipairs(treesitter.get_installed()) do installed[lang] = true end
local missing = {}
for _, lang in ipairs(ensure_installed) do
    if not installed[lang] then table.insert(missing, lang) end
end

local function start_treesitter(buf)
    if not vim.api.nvim_buf_is_valid(buf) or disable_treesitter(buf) then return end
    if not pcall(vim.treesitter.start, buf) then return end
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("nvim_mini_treesitter", { clear = true }),
    callback = function(ev) start_treesitter(ev.buf) end,
})

if #missing > 0 then
    vim.schedule(function()
        ensure_treesitter_cli(function(cli_ready)
            if not cli_ready then
                vim.notify("Tree-sitter parsers skipped because the CLI is unavailable", vim.log.levels.WARN)
                return
            end
            treesitter.install(missing, { summary = true }):await(function(err)
                if err then
                    vim.notify("Tree-sitter parser installation failed: " .. tostring(err), vim.log.levels.WARN)
                    return
                end
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do start_treesitter(buf) end
            end)
        end)
    end)
end
