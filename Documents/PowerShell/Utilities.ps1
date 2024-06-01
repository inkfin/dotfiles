# Taken from https://stackoverflow.com/questions/42566799/how-to-bring-focus-to-window-by-process-name
function Show-Window {
  param(
    [Parameter(Mandatory)]
    [string] $ProcessName
  )

  # As a courtesy, strip '.exe' from the name, if present.
  $ProcessName = $ProcessName -replace '\.exe$'

  # Get the PID of the first instance of a process with the given name
  # that has a non-empty window title.
  # NOTE: If multiple instances have visible windows, it is undefined
  #       which one is returned.
  $hWnd = (Get-Process -ErrorAction Ignore $ProcessName).Where({ $_.MainWindowTitle }, 'First').MainWindowHandle

  if (-not $hWnd) { Throw "No $ProcessName process with a non-empty window title found." }

  $type = Add-Type -PassThru -NameSpace Util -Name SetFgWin -MemberDefinition @'
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);    
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool IsIconic(IntPtr hWnd);    // Is the window minimized?
'@ 

  # Note: 
  #  * This can still fail, because the window could have been closed since
  #    the title was obtained.
  #  * If the target window is currently minimized, it gets the *focus*, but its
  #    *not restored*.
  $null = $type::SetForegroundWindow($hWnd)
  # If the window is minimized, restore it.
  # Note: We don't call ShowWindow() *unconditionally*, because doing so would
  #       restore a currently *maximized* window instead of activating it in its current state.
  if ($type::IsIconic($hwnd)) {
    $type::ShowWindow($hwnd, 9) # SW_RESTORE
  }

}

# wezterm suggested OSC 7 Escape sequence to set the working directory
# https://wezfurlong.org/wezterm/shell-integration.html#osc-7-on-windows-with-cmdexe
# powershell without starship
function prompt {
    $p = $executionContext.SessionState.Path.CurrentLocation
    $osc7 = ""
    if ($p.Provider.Name -eq "FileSystem") {
        $ansi_escape = [char]27
        $provider_path = $p.ProviderPath -Replace "\\", "/"
        $osc7 = "$ansi_escape]7;file://${env:COMPUTERNAME}/${provider_path}${ansi_escape}\"
    }
    "${osc7}PS $p$('>' * ($nestedPromptLevel + 1)) ";
}
# powershell with starship
$prompt = ""
function Invoke-Starship-PreCommand {
    $current_location = $executionContext.SessionState.Path.CurrentLocation
    if ($current_location.Provider.Name -eq "FileSystem") {
        $ansi_escape = [char]27
        $provider_path = $current_location.ProviderPath -replace "\\", "/"
        $prompt = "$ansi_escape]7;file://${env:COMPUTERNAME}/${provider_path}$ansi_escape\"
    }
    $host.ui.Write($prompt)
}

# cmake commands
function cmc  { cmake -S . -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B $args }
function cmcv { cmake -S . -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_TOOLCHAIN_FILE="$env:VCPKG_ROOT\scripts\buildsystems\vcpkg.cmake" -B $args }
function cmb  { cmake --build $args }

function preview {
    param(
        [string]$filePath,
        [int]$width = 800,
        [int]$height = 600,
        [float]$horizontal_position = 0,
        [float]$vertical_position = 0
    )
    & $HOME/scripts/previewer.ps1 $filePath $width $height $horizontal_position $vertical_position
}
