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
        $ENVPATH = $ENVPATH + $PATH + [IO.Path]::PathSeparator
        # Write-Host "$ENVPATH"
        $env:PATH = $ENVPATH
        [Environment]::SetEnvironmentVariable( "Path", $ENVPATH, "User" )
        Write-Host "'$Path' is appended to User-Path."
    }
}

# ENVs
$env:OPENER = "vim"
$env:EDITOR = "code"

# Aliases
# function list-files { param($file) Get-ChildItem $file | Format-Table }
# Set-Alias -Name l -Value list-files
# Set-Alias -Name ll -value list-files -Option AllScope -Description 'List directory contents in long format'
# function list-hidden-files { param($file) Get-ChildItem -Hidden $file | Format-Table } 
# Set-Alias -Name la -value list-hidden-files -Option AllScope -Description 'List directory contents including hidden files'
Set-Alias -Name ls -Value 'lsd'
function l   { lsd -l }
function la  { lsd -a }
function lla { lsd -la }
function lt  { lsd --tree }

function open-invoke { param($file) Invoke-Item $file }
function open-start { param($file) Start-Process $file }
Set-Alias -Name open -Value open-start -Option AllScope -Description 'Opens a file in its default application'

function source { . $PROFILE }
function ee { exit }

# gp, gP, gc, gcm are occupied by powershell cmdlets, just use lazygit
function gst { git status }

Set-Alias -Name lg -Value 'lazygit'
Set-Alias -Name ra -Value 'lf'
Set-Alias -Name nvim -Value 'nn'
Set-Alias -Name v -Value 'nn'
Set-Alias -Name vim -Value 'nvim'
# Set-Alias -Name nvi -Value 'neovide' # nv is occupied by New-Variable
function nvi { param($file) Start-Process -NoNewWindow neovide $file }
Set-Alias -Name cz -Value 'chezmoi'
function vimrc { nvim "$HOME\.local\share\chezmoi\dot_config\nvim\init.lua" }
function pwshrc { nvim "$HOME\.local\share\chezmoi\Documents\Powershell\Microsoft.PowerShell_profile.ps1" }
function rimerc { nvim "$HOME\.local\share\chezmoi\dot_config\Rime\default.custom.yaml" }
function custom_phrase { nvim "$HOME\.local\share\chezmoi\dot_config\Rime\custom_phrase.txt" }

function nn {
    & "$HOME\.local\neovim\bin\nvim.exe" $args
}
# function newquake { wt -w _quake --title quake musicfox `; sp -V -s .8 -d D:\dev\Code --title quake }
function newquake { wt -w _quake --title quake wsl -d Ubuntu -- tmux attach-session -t popup }

# oh-my-posh
# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/wholespace.omp.json" | Invoke-Expression


# starship
function Invoke-Starship-TransientFunction {
  &starship module character
}

. "$PSScriptRoot/PSReadLine_config.ps1"
. "$PSScriptRoot/Utilities.ps1"
. "$($(Get-Item $(Get-Command scoop).Path).Directory.Parent.FullName)\apps\scoop-completion\current\add-profile-content.ps1"

Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

Enable-TransientPrompt

# imports
Import-Module PSFzf

# local bin
Append-UserPath("$HOME\.local\bin")
Append-UserPath("$HOME\.local\neovim\bin")

# CUDA environment
Init-EnvironmentVariable CUDA_PATH_V12_1 "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.1"
Init-EnvironmentVariable CUDA_PATH_V11_2 "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.2"
Init-EnvironmentVariable CUDA_PATH "$env:CUDA_PATH_V12_1"
Append-UserPath "$env:CUDA_PATH\bin"
Append-UserPath "$env:CUDA_PATH\libnvvp"

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

# vcpkg
Init-EnvironmentVariable VCPKG_ROOT "$HOME\dev\vcpkg"
Append-UserPath $env:VCPKG_ROOT
Append-UserPath $HOME\.local\bin
$env:LLVMInstallDir = "$HOME\scoop\apps\llvm\current"
Import-Module (Join-Path $env:VCPKG_ROOT "\scripts\posh-vcpkg")

Import-Module scoop-completion
