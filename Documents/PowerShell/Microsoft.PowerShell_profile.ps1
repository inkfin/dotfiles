# ENVs
$env:OPENER = "nvim"
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
    param($file)
    $nvimPath = "$HOME\.local\neovim\nvim-win64\bin\nvim.exe"
    if ($null -ne $file) {
        & $nvimPath $file
    } else {
        & $nvimPath
    }
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
Import-Module 'D:\dev\vcpkg\scripts\posh-vcpkg'
Import-Module PSFzf

# local bin
$env:PATH = "$HOME\.local\bin;$env:PATH"
$env:PATH = "C:\Program Files\TerminalTools;$env:PATH"

# CUDA environment
$env:CUDA_PATH_V12_1 = "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.1"
$env:CUDA_PATH_V11_2 = "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.2"
$env:CUDA_PATH = "$env:CUDA_PATH_V12_1"

$env:PATH = "$env:CUDA_PATH\bin;$env:PATH"
$env:PATH = "$env:CUDA_PATH\libnvvp;$env:PATH"

# C++ environment
#
## toolset
# $env:CC = "$HOME\scoop\apps\mingw\current\bin\gcc.EXE"
# $env:CXX = "$HOME\scoop\apps\mingw\current\bin\g++.EXE"
# $env:CC = "C:\Users\11096\scoop\apps\llvm\current\bin\clang.EXE"
# $env:CXX = "C:\Users\11096\scoop\apps\llvm\current\bin\clang++.EXE"
$env:CC = "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.39.33519\bin\Hostx64\x64\cl.exe"
$env:CXX = $env:CC

# vcpkg
$env:VCPKG_ROOT = "D:\dev\vcpkg"
$env:PATH = "$env:VCPKG_ROOT;$env:PATH"
$env:PATH = "$HOME\.local\bin;$env:PATH"
$env:LLVMInstallDir = "$HOME\scoop\apps\llvm\current"
Import-Module scoop-completion
