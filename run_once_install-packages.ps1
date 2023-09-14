if (-not (Test-Path "$HOME\.init_flag")) {

Write-host "Installing WINGET packages ..." -f Green

winget install SomePythonThings.WingetUIStore
winget install Yuanli.uTools
winget install XP89DCGQ3K6VLD  # Powertoys
winget install AgileBits.1Password
winget install AutoHotkey.AutoHotkey
winget install Fndroid.ClashForWindows
winget install Valve.Steam

# winget install JanDeDobbeleer.OhMyPosh -s winget
winget install Starship.Starship

if (-not (Test-Path "$HOME\Documents\WindowsPowerShell")) {
    Write-host "WindowsPowerShell config doesn't exists, creating now..." -f Green
    mkdir "$HOME\Documents\WindowsPowerShell"
    "mklink %USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 %USERPROFILE%\.config\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" | cmd
}


# Update PowershellGet for pwsh < 5.1
Install-Module -Name PowerShellGet -Force
# Install Packages
Install-Module ZLocation -Scope CurrentUser; Import-Module ZLocation;
Install-Module -Name PSReadLine; Import-Module PSReadLine;

.$PROFILE
}
