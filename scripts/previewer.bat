@echo off

set item=%1

IF not x%item:.md=%==x%item% (
	glow %1 -s dark
) ELSE IF not x%item:.7z=%==x%item% (
	7z l %1 | bat
) ELSE IF not x%item:.zip=%==x%item% (
	unzip -l %1 | bat
) ELSE IF not x%item:.rar=%==x%item% (
	unrar l %1 | bat
) ELSE IF not x%item:.pdf=%==x%item% (
    powershell -Command "pdftotext" %1 - | bat
) ELSE IF not x%item:.jpg=%==x%item% (
    chafa %1
) ELSE IF not x%item:.jpeg=%==x%item% (
    chafa %1
) ELSE IF not x%item:.png=%==x%item% (
    chafa %1
) ELSE IF not x%item:.webp=%==x%item% (
    chafa %1
) ELSE (
	bat --color=always --line-range=:200 %1
)
