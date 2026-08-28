@echo off
rem Download the wanxiang LTS grammar model (~400MB) into the Rime user dir.
rem %APPDATA%\Rime is a symlink to %USERPROFILE%\.config\Rime (see
rem AppData\Roaming\symlink_Rime.tmpl), so the file lands in one place for
rem both Weasel and rime-ls. Deliberately outside chezmoi: the
rem .external.rime_gram flag only switches the schema config, this script
rem fetches the file so `chezmoi update -R` never pulls it.
rem
rem Usage:
rem   rime-gram          download
rem   rime-gram --force  delete and re-download (after an LTS model update)

set "OUT=%USERPROFILE%\.config\Rime\wanxiang-lts-zh-hans.gram"
set "URL=https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/wanxiang-lts-zh-hans.gram"

if "%~1"=="--force" if exist "%OUT%" del /f /q "%OUT%"

if exist "%OUT%" (
    echo already downloaded: %OUT% ^(use --force to re-download^)
    exit /b 0
)

where curl.exe >nul 2>nul
if errorlevel 1 (
    echo error: curl.exe not found, install Windows 10 1803+ update or curl manually >&2
    exit /b 1
)

curl -fL --progress-bar -o "%OUT%" "%URL%"
if errorlevel 1 (
    echo error: download failed >&2
    exit /b 1
)
echo done: %OUT%
echo 部署：右键任务栏小狼毫图标 → 重新部署
