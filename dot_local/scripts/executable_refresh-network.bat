@echo off
setlocal EnableExtensions
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [1/2] Requesting administrator privileges...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)
set "PS=%temp%\refresh-network-%random%.ps1"
more +13 "%~f0" > "%PS%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS%"
del "%PS%" >nul 2>&1
exit /b
param(
    [switch]$SkipAdapterRestart
)

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process -FilePath "powershell" -Verb RunAs -ArgumentList "-NoExit -ExecutionPolicy Bypass -File `"$PSCommandPath`" $($args -join ' ')"
    exit
}

$ErrorActionPreference = 'Continue'

function Write-Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg) { Write-Host "    $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "    $msg" -ForegroundColor Yellow }

Write-Host '================== Network One-Click Refresh ==================' -ForegroundColor White
Write-Host ("Time: " + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))

$active = Get-NetAdapter | Where-Object {
    $_.Status -eq 'Up' -and $_.InterfaceDescription -notmatch 'Virtual|Loopback|Wintun|TAP|Hyper-V'
}
Write-Ok "Active adapters: $($active.Name -join ', ')"

Write-Step '1/8 Saving current DNS configuration'
$dnsBefore = Get-DnsClientServerAddress -AddressFamily IPv4 |
    Where-Object { $_.ServerAddresses -and $_.InterfaceAlias -in $active.Name } |
    ForEach-Object { [PSCustomObject]@{ Alias = $_.InterfaceAlias; Addresses = $_.ServerAddresses } }
if ($dnsBefore) {
    $dnsBefore | ForEach-Object { Write-Ok "    $($_.Alias): $($_.Addresses -join ', ')" }
}

Write-Step '2/8 Flushing DNS and ARP cache'
ipconfig /flushdns | Out-Null
arp -d * | Out-Null
Write-Ok 'done'

Write-Step '3/8 Resetting Winsock / TCP-IP stack'
netsh winsock reset | Out-Null
netsh int ip reset | Out-Null
netsh int ipv6 reset | Out-Null
netsh int tcp set global autotuninglevel=normal | Out-Null
netsh int tcp set global ecncapability=disabled | Out-Null
Write-Ok 'done'

Write-Step '4/8 Clearing leftover proxy settings'
netsh winhttp reset proxy | Out-Null
$ies = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
Set-ItemProperty -Path $ies -Name ProxyEnable -Value 0 -Type DWord
Set-ItemProperty -Path $ies -Name ProxyServer -Value ''
Write-Ok 'system proxy off, winhttp direct'

Write-Step '5/8 Releasing and renewing IP'
ipconfig /release | Out-Null
Start-Sleep -Seconds 2
ipconfig /renew | Out-Null
Start-Sleep -Seconds 2
Write-Ok 'done'

Write-Step '6/8 Restarting adapters'
if (-not $SkipAdapterRestart -and $active) {
    foreach ($a in $active) {
        Write-Ok "    restarting $($a.Name) ..."
        Disable-NetAdapter -Name $a.Name -Confirm:$false -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3
        Enable-NetAdapter -Name $a.Name -Confirm:$false -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3
    }
} else {
    Write-Warn 'skipped (adapter restart disabled)'
}

Write-Step '7/8 Restoring DNS configuration'
foreach ($d in $dnsBefore) {
    if ((Get-NetAdapter -Name $d.Alias -ErrorAction SilentlyContinue).Status -eq 'Up') {
        Set-DnsClientServerAddress -InterfaceAlias $d.Alias -ServerAddresses $d.Addresses -ErrorAction SilentlyContinue
        Write-Ok "    $($d.Alias) -> $($d.Addresses -join ', ')"
    }
}
ipconfig /flushdns | Out-Null

Write-Step '8/8 Connectivity verification'
$gw = (Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Select-Object -First 1).NextHop
if ($gw) {
    $r = Test-Connection -ComputerName $gw -Count 4 -Quiet
    Write-Ok "    gateway $gw reachable: $r"
}
$dns = (Resolve-DnsName www.baidu.com -Type A -ErrorAction SilentlyContinue | Where-Object { $_.Type -eq 'A' } | Select-Object -First 1).IPAddress
if ($dns) { Write-Ok "    DNS resolves www.baidu.com -> $dns" }
else { Write-Warn '    DNS resolution failed!' }

Write-Step 'Current DNS / proxy / gateway'
$cur = Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object { $_.ServerAddresses } | Select-Object InterfaceAlias, ServerAddresses
$cur | ForEach-Object { Write-Ok "    $($_.InterfaceAlias): $($_.ServerAddresses -join ', ')" }
Write-Ok "    system proxy enabled: $((Get-ItemProperty $ies).ProxyEnable)"
Write-Ok "    gateway: $gw"

Write-Host "`n================== Done ==================" -ForegroundColor White
Write-Warn 'Note: winsock/ip resets may need a reboot to fully take effect.'
Write-Warn 'If the ISP line is throttled, this script cannot speed it up; restart your modem/router to re-dial.'
Write-Host ''
pause
