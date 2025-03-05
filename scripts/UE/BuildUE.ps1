param (
    [string]$Mode = "build",
    [string]$ProjectDir = (Get-Location),
    [string]$EnginePath = "",
    [string]$Generator = "CMake",
    [string]$Target = ""
)

# 手动指定默认 Unreal Engine 目录（如果未提供 -EnginePath）
if (-not $EnginePath) {
    $EnginePath = "C:\Path\To\UnrealEngine"  # 请手动填写默认路径
}

# 获取 Project Name
$uproject = Get-ChildItem -Path $ProjectDir -Filter "*.uproject" | Select-Object -First 1
if (-not $uproject) {
    Write-Host "Error: No .uproject file found in $ProjectDir" -ForegroundColor Red
    exit 1
}
$ProjectName = [System.IO.Path]::GetFileNameWithoutExtension($uproject.Name)
$ProjectPath = "$ProjectDir\$uproject"

# 处理不同的模式
switch ($Mode) {
    "compile_commands" {
        $cmd = "& `"$EnginePath\Engine\Build\BatchFiles\Build.bat`" -Mode=GenerateClangDatabase -Progress -Game -Engine -Project=`"$ProjectPath`" -OutputDir=`"$ProjectDir`" UnrealEditor Win64 Development"
    }
    "projectfiles" {
        $cmd = "& `"$EnginePath\GenerateProjectFiles.bat`" -Projectfiles -$Generator -Project=`"$ProjectPath`" -Game -Engine -Dotnet"
    }
    "build" {
        if (-not $Target) {
            $Target = "${ProjectName}Editor Win64 Development"
        }
        $cmd = "& `"$EnginePath\Engine\Build\BatchFiles\Build.bat`" $Target `"-project=$ProjectPath`" -progress -waitmutex -frommsbuild"
    }
    "buildengine" {
        if (-not $Target) {
            $Target = "UnrealGame Win64 Development"
        }
        $cmd = "&
`"$EnginePath\Engine\Build\BatchFiles\Build.bat`" $Target -progress -waitmutex -frommsbuild"
    }
    default {
        Write-Host "Error: Invalid Mode '$Mode'. Allowed values: compile_commands, build, projectfiles" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Running: $cmd" -ForegroundColor Cyan
Invoke-Expression $cmd

