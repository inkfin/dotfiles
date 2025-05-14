param(
    [Parameter(Mandatory=$true)]
    [string]$dir1,

    [Parameter(Mandatory=$true)]
    [string]$dir2
)

function Get-FileHashTable($basePath) {
    $table = @{}
    Get-ChildItem -Path $basePath -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($basePath.Length).TrimStart('\')
        $table[$rel] = $_.FullName
    }
    return $table
}

$files1 = Get-FileHashTable $dir1
$files2 = Get-FileHashTable $dir2

$allKeys = $files1.Keys + $files2.Keys | Sort-Object -Unique

foreach ($key in $allKeys) {
    $path1 = $files1[$key]
    $path2 = $files2[$key]

    if (-not $path1) {
        Write-Host "Only in dir2: $key"
    } elseif (-not $path2) {
        Write-Host "Only in dir1: $key"
    } else {
        $size1 = (Get-Item $path1).Length
        $size2 = (Get-Item $path2).Length
        if ($size1 -ne $size2) {
            Write-Host "Different size: $key ($size1 vs $size2)"
        } else {
            $hash1 = Get-FileHash $path1 -Algorithm SHA256
            $hash2 = Get-FileHash $path2 -Algorithm SHA256
            if ($hash1.Hash -ne $hash2.Hash) {
                Write-Host "Same size, different content: $key"
            }
        }
    }
}

