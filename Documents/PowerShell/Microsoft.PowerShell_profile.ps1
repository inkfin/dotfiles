# Aliases
function list-files { param($file) Get-ChildItem $file | Format-Table }
Set-Alias -Name l -Value list-files
Set-Alias -Name ll -value list-files -Option AllScope -Description 'List directory contents in long format'
function list-hidden-files { param($file) Get-ChildItem -Hidden $file | Format-Table } 
Set-Alias -Name la -value list-hidden-files -Option AllScope -Description 'List directory contents including hidden files'

function open-invoke { param($file) Invoke-Item $file }
function open-start { param($file) Start-Process $file }
Set-Alias -Name open -Value open-start -Option AllScope -Description 'Opens a file in its default application'

function ee { exit }

# gp, gP, gc, gcm are occupied by powershell cmdlets, just use lazygit
function gst { git status }

Set-Alias -Name lg -Value 'lazygit'
Set-Alias -Name ra -Value 'lf'
Set-Alias -Name v -Value 'nvim'
Set-Alias -Name vim -Value 'nvim'
Set-Alias -Name nvi -Value 'neovide' # nv is occupied by New-Variable
Set-Alias -Name cz -Value 'chezmoi'
function vimrc { nvim "$HOME\.local\share\chezmoi\dot_config\nvim\init.lua" }

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

Enable-TransientPrompt

# imports
Import-Module scoop-completion
Import-Module 'C:\dev\vcpkg\scripts\posh-vcpkg'
