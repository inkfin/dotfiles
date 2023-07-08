function l { ls }
function la() {
    param([string] $fp)
    Get-ChildItem -Force $fp
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
function vim() {
    param([string] $fp)
    nvim $fp
}
function cz() {
    param([string] $par)
    chezmoi $par
}
function vimrc { nvim "C:\Users\Administrator\.local\share\chezmoi\dot_config\nvim\init.vim" }

# oh-my-posh
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/wholespace.omp.json" | Invoke-Expression
