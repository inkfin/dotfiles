if (-not (Test-Path "$HOME\.init_flag")) {

Write-host "Installing WINGET packages ..." -f Green

winget install SomePythonThings.WingetUIStore
winget install Yuanli.uTools
winget install XP89DCGQ3K6VLD  # Powertoys
winget install AgileBits.1Password
winget install AutoHotkey.AutoHotkey
# winget install Fndroid.ClashForWindows
winget install Valve.Steam

# winget install JanDeDobbeleer.OhMyPosh -s winget

winget install Microsoft.PowerShell
winget install --id Microsoft.WindowsTerminal -e

# Update PowershellGet for pwsh < 5.1
Install-Module -Name PowerShellGet -Force
# Install Packages
Install-Module -Name PSReadLine;

# Scoop installation instructions are in README.md
Write-host "Installing scoop packages ..." -f Green
scoop install fzf psfzf starship scoop-completion
scoop bucket add extras
scoop install 7zip git aria2
scoop install zoxide lsd bottom
scoop install cmake python
scoop install neovim ripgrep bat fd glow chafa

# if (-not (Test-Path "$HOME\Documents\WindowsPowerShell")) {
#     Write-host "WindowsPowerShell config doesn't exists, creating now..." -f Green
#     mkdir "$HOME\Documents\WindowsPowerShell"
#     "mklink %USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 %USERPROFILE%\.config\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" | cmd
# }

.$PROFILE

}
else
{

Write-host "$HOME\.init_flag found, skipping boost script." -f Green

}
