# windows-specific config
if $nu.os-info.name == "windows" {
    let file_exe = "C:/Program Files/Git/usr/bin/file.exe"
    if ($file_exe | path exists) {
        $env.YAZI_FILE_ONE = $file_exe
    }
}

# vim: ft=nu