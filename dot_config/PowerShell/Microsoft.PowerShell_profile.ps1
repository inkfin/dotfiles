# PowerShell_profile
# pwsh.exe
# Subscripts include: PSReadLine_config.ps1, Utilities.ps1

function Init-EnvironmentVariable($Name, $Val) {
    $OldValue = [Environment]::GetEnvironmentVariable($Name, "User")
    if ($null -eq $OldValue) {
        Set-Item -Path env:$Name -Value $Val
        [Environment]::SetEnvironmentVariable($Name, $Val, "User")
        Write-Host "Environment variable '$Name' set to '$Val'."
    }
}

function Set-EnvironmentVariable($Name, $Val) {
    $OldValue = [Environment]::GetEnvironmentVariable($Name, "User")
    if ($OldValue -ne $Val) {
        Set-Item -Path env:$Name -Value $Val
        [Environment]::SetEnvironmentVariable($Name, $Val, "User")
        Write-Host "Environment variable '$Name' set to '$Val'."
    }
}

function Append-UserPath($Path) {
    $ENVPATH = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($ENVPATH -notlike "*$Path*") {
        $ENVPATH = $ENVPATH + [IO.Path]::PathSeparator + $PATH
        # Write-Host "$ENVPATH"
        $env:PATH = $ENVPATH
        [Environment]::SetEnvironmentVariable( "Path", $ENVPATH, "User" )
        Write-Host "'$Path' is appended to User-Path."
    }
}

# ENVs
$env:OPENER = "Invoke-Item"
$env:EDITOR = "nvim"

# Aliases
# function list-files { param($file) Get-ChildItem $file | Format-Table }
# Set-Alias -Name l -Value list-files
# Set-Alias -Name ll -value list-files -Option AllScope -Description 'List directory contents in long format'
# function list-hidden-files { param($file) Get-ChildItem -Hidden $file | Format-Table } 
# Set-Alias -Name la -value list-hidden-files -Option AllScope -Description 'List directory contents including hidden files'
Set-Alias -Name l -Value 'ls'
function ll  { lsd -l }
function la  { lsd -la }
function lt  { lsd --tree }

function open-invoke { param($file) Invoke-Item $file }
function open-start { param($file) Start-Process $file }
Set-Alias -Name open -Value open-start -Option AllScope -Description 'Opens a file in its default application'

function source { . $PROFILE }
function ee { exit }

# gp, gP, gc, gcm are occupied by powershell cmdlets, just use lazygit
function gst { git status }

Set-Alias -Name lg -Value 'lazygit'
# Set-Alias -Name ra -Value 'lf'
# Set-Alias -Name nvim -Value 'nn'
Set-Alias -Name v -Value 'nvim'
Set-Alias -Name vim -Value 'nvim'
Set-Alias -Name nvi -Value 'neovide'
function vcn { param($file) nvim --cmd 'let g:rime=v:true' $file }
function nvs { & nvim --listen localhost:6789 --cmd "let safequit=v:true" @args }
function nvc { & nvim --server localhost:6789 --remote-ui }
Set-Alias -Name cz -Value 'chezmoi'
function vimrc { & nvim "$HOME\.local\share\chezmoi\dot_config\nvim\init.lua" }
function vimpwsh { & nvim "$HOME\.local\share\chezmoi\dot_config\Powershell\Microsoft.PowerShell_profile.ps1" }
function vimrime { & nvim "$HOME\.local\share\chezmoi\dot_config\Rime\default.custom.yaml" }
function custom_phrase { & nvim "$HOME\.local\share\chezmoi\dot_config\Rime\custom_phrase.txt" }
function vimtmpl { & nvim "$HOME\.local\share\chezmoi\template"}

function nn {
    & "$HOME\.local\neovim\bin\nvim.exe" $args
}
function newquake { wt -w _quake -d $HOME\Documents\WorkNotes --title quake `; sp -V -p "PowerShell" -s .35 --title quake `; sp -H -p "PowerShell" -s .8 --title quake }
# function newquake { wt -w _quake --title quake wsl -d Ubuntu -- tmux attach-session -t popup }

# yazi
Init-EnvironmentVariable YAZI_FILE_ONE "C:\Program Files\Git\usr\bin\file.exe"
Set-Alias -Name ra -Value 'yazi'
function rag {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath $cwd
    }
    Remove-Item -Path $tmp
}

# local bin
Append-UserPath("$HOME\.local\bin")
Append-UserPath("$HOME\.local\neovim\bin")

# Init-EnvironmentVariable COMSPEC "pwsh.exe"

# CUDA environment
# Init-EnvironmentVariable CUDA_PATH_V13_0 "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.0"
Init-EnvironmentVariable CUDA_PATH_V12_9 "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.9"
Init-EnvironmentVariable CUDA_PATH "$env:CUDA_PATH_V12_9"
Append-UserPath "$env:CUDA_PATH\bin"

# C++ environment
#
## toolset
## Only set for current session
$CC_GCC = "$HOME\scoop\apps\mingw\current\bin\gcc.EXE"
$CXX_GCC = "$HOME\scoop\apps\mingw\current\bin\g++.EXE"
$CC_CLANG = "$HOME\scoop\apps\llvm\current\bin\clang.EXE"
$CXX_CLANG = "$HOME\scoop\apps\llvm\current\bin\clang++.EXE"
function Use-CC($cc) {
    if ($cc -match "clang") {
        $env:CC = $CC_CLANG
        $env:CXX = $CXX_CLANG
    }
    elseif ($cc -match "gcc") {
        $env:CC = $CC_GCC
        $env:CXX = $CXX_GCC
    } else #if ($cc -match "msvc")
    {
        $env:CC = ""
        $env:CXX = ""
    }
}

## libclang
$env:LIBCLANG_PATH = "$HOME\scoop\apps\llvm\current\lib"

# vcpkg
Init-EnvironmentVariable VCPKG_ROOT "$HOME\dev\vcpkg"
Append-UserPath $env:VCPKG_ROOT
$env:LLVMInstallDir = "$HOME\scoop\apps\llvm\current"
Import-Module (Join-Path $env:VCPKG_ROOT "\scripts\posh-vcpkg")

# Scoop
Init-EnvironmentVariable SCOOP_HOME "$HOME\scoop"
Init-EnvironmentVariable SCOOP_CONFIG_PATH "$env:SCOOP_HOME\persist"

# Rust
Init-EnvironmentVariable RUSTUP_HOME "$env:SCOOP_HOME\persist\rustup\.rustup"
Init-EnvironmentVariable CARGO_HOME "$env:SCOOP_HOME\scoop\persist\rustup\.cargo"

# Fzf
Import-Module PSFzf

. "$PSScriptRoot/PSReadLine_config.ps1"
. "$PSScriptRoot/Utilities.ps1"

# Post init

# oh-my-posh
#oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/wholespace.omp.json" | Invoke-Expression

# starship
function Invoke-Starship-TransientFunction {
  &starship module character
}
Invoke-Expression (&starship init powershell)
Enable-TransientPrompt # after starship init
# zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })
# scoop
# . "$($(Get-Item $(Get-Command scoop).Path).Directory.Parent.FullName)\apps\scoop-completion\current\add-profile-content.ps1"
Import-Module scoop-completion
