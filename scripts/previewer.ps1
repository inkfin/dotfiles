param(
    [string]$filePath,
    [int]$width = 800,
    [int]$height = 600,
    [float]$horizontal_position = 0,
    [float]$vertical_position = 0
)

& python $HOME\scripts\lf_previewer.py $filePath $width $height $horizontal_position $vertical_position

# $extension = [System.IO.Path]::GetExtension($filePath).ToLower()

# switch ($extension) {
#     ".zip" { & unzip -l $filePath | bat }
#     ".rar" { & "unrar" l $filePath | bat }
#     ".7z"  { & "7z" l $filePath }
#     # download exe from https://docs.apryse.com/documentation/cli/download/
#     ".pdf" { & "pdf2text" $filePath }
#     ".jpg" { & "chafa" $filePath }
#     ".jpeg" { & "chafa" $filePath }
#     ".webp" { & "chafa" $filePath }
#     ".png" { & "chafa" $filePath }
#     ".md" { & "glow" $filePath -s dark }
#     default { & "bat" --color=always --line-range=:200 $filePath }
# }
