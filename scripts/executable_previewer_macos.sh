#!/usr/bin/env sh

case "$1" in
*.tar*) tar tf "$1" ;;
*.zip) unzip -l "$1" ;;
*.rar) unrar l "$1" ;;
*.7z) 7z l "$1" ;;
*.pdf) pdftotext "$1" - ;;
*.md) glow "$1" -s dark ;;
*.jpg | *.jpeg | *.png | *.webp | *.bmp)
	# ${HOME}/.iterm2/imgcat --height "$(echo "$2*0.9/1" | bc)" "$1"
	chafa --animate off "$1" -s "$2x$3"
	;;
*) bat --color=always --line-range=:200 "$1" ;;
esac
exit 127
