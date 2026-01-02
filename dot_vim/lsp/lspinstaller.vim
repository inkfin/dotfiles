if !has("vim9script") || v:version < 900 || !g:enable_lsp || g:force_use_ale
    finish
endif
vim9script

# Base LSP installation directory
const lspBaseDir = expand('~/.vim/lsp')

# Ensure the base directory exists
if !isdirectory(lspBaseDir)
    mkdir(lspBaseDir, 'p')
endif

# Ensure installed LSPs tracking
if !exists("g:installed_lsps")
    g:installed_lsps = {}
endif

# Function to load JSON config from a file
export def LoadJSONConfig(filepath: string): dict<any>
    if !filereadable(filepath)
        throw "JSON file not found: " .. filepath
    endif

    # Read and parse JSON
    var json_string = join(readfile(filepath), "\n")
    return json_decode(json_string)
enddef

# Generate install command dynamically
export def GetInstallCommand(config: dict<any>): string
    var method = get(config, "install_method", "")
    var packageName = get(config, "package_name", "")
    if method == "" || packageName == ""
        throw "Invalid install config: missing install_method or package_name"
    endif

    var installDir = lspBaseDir
    if method == "bun"
        return "bun i " .. packageName .. " --production --cwd " .. installDir
    elseif method == "npm"
        return "npm install --global --prefix " .. installDir .. " " .. packageName
    endif

    throw "Unsupported install method: " .. method
enddef

# Generate bin command dynamically
export def GetBinCommand(config: dict<any>): string
    var method = get(config, "install_method", "")
    var binName = get(config, "bin_name", "")
    if method == "" || binName == ""
        throw "Invalid bin config: missing install_method or bin_name"
    endif

    var installDir = lspBaseDir .. "/node_modules"
    if method == "bun"
        return "bun run -b " .. installDir .. "/" .. binName
    elseif method == "npm"
        return installDir .. "/.bin/" .. binName
    endif

    throw "Unsupported bin method: " .. method
enddef

# Install an LSP
export def InstallLSP(name: string, config: dict<any>): string
    var installCmd = GetInstallCommand(config)
    var binCmd = GetBinCommand(config)

    # Ensure the LSP directory exists
    if !isdirectory(lspBaseDir)
        mkdir(lspBaseDir, 'p')
    endif

    # Get the actual install directory for verification
    var method = get(config, "install_method", "")
    var packageName = get(config, "package_name", "")
    var binName = get(config, "bin_name", "")

    var packageDir = lspBaseDir .. "/node_modules/" .. packageName
    var binPath = lspBaseDir .. "/node_modules/.bin/" .. binName

    # Check if already installed
    if isdirectory(packageDir) || filereadable(binPath) || executable(binPath)
        g:installed_lsps[name] = binCmd
        return binCmd
    endif

    # Execute installation
    execute('silent !' .. installCmd)

    # Verify installation again
    if isdirectory(packageDir) || filereadable(binPath) || executable(binPath)
        g:installed_lsps[name] = binCmd
        return binCmd
    endif

    throw "Failed to install " .. name .. "!"
enddef

# Ensure all required LSPs are installed
export def EnsureLSPs()
    if !exists("g:ensure_installed") || type(g:ensure_installed) != v:t_dict
        throw "g:ensure_installed is missing or invalid!"
    endif

    for lsp in keys(g:ensure_installed)
        try
            var lspPath = InstallLSP(lsp, g:ensure_installed[lsp])
            g:installed_lsps[lsp] = lspPath  # Only update if installation succeeds
        catch
            echohl ErrorMsg
            echom "EnsureLSPs Error: " .. v:exception
            echohl None
        endtry
    endfor
enddef

# Load JSON config and ensure LSPs
try
    g:ensure_installed = LoadJSONConfig(expand("~/.vim/plugins/lsp_config.json"))
    EnsureLSPs()
catch
    echohl ErrorMsg
    echom "Failed to load or install LSPs: " .. v:exception
    echohl None
endtry
