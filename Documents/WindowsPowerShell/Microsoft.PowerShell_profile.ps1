# Aliases
function l { ls }
function la() {
    param([string] $fp)
    Get-ChildItem -Force $fp
}

function open() {
    param([string] $par)
    Invoke-Item $par
}

function ee { exit }

function gp { git pull }
function gP { git push }
function ga() {
    param([string] $fp)
    git add $fp
}
function gcm() {
    param([string] $msg)
    git commit -m $msg
}
function gst { git status }
function lg { lazygit }
function ra() {
    param([string] $fp)
    lf $fp
}
function v() {
    param([string] $fp)
    nvim $fp
}
function vim() {
    param([string] $fp)
    nvim $fp
}
function nvi() {
    param([string] $fp)
    neovide $fp
}
function cz() {
    param([string] $par)
    chezmoi $par
}
function vimrc { nvim "$HOME\.local\share\chezmoi\dot_config\nvim\init.lua" }

# oh-my-posh
# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/wholespace.omp.json" | Invoke-Expression


# starship
function Invoke-Starship-TransientFunction {
  &starship module character
}

. "$PSScriptRoot/PSReadLine_config.ps1"
. "$($(Get-Item $(Get-Command scoop).Path).Directory.Parent.FullName)\apps\scoop-completion\current\add-profile-content.ps1"

Invoke-Expression (&starship init powershell)

Enable-TransientPrompt

# imports
Import-Module scoop-completion