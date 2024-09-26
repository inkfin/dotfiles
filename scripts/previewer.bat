@echo off

python %userprofile%\\scripts\\lf_previewer.py %1 %2 %3 %4 %5

REM IF not x%item:.md=%==x%item% (
REM 	glow %1 -s dark
REM ) ELSE IF not x%item:.7z=%==x%item% (
REM 	7z l %1 | bat
REM ) ELSE IF not x%item:.zip=%==x%item% (
REM 	unzip -l %1 | bat
REM ) ELSE IF not x%item:.rar=%==x%item% (
REM 	unrar l %1 | bat
REM ) ELSE IF not x%item:.pdf=%==x%item% (
REM     REM Download exe from https://docs.apryse.com/documentation/cli/download/
REM     pdf2text %1 | bat
REM ) ELSE IF not x%item:.jpg=%==x%item% (
REM     chafa -f sixel %1
REM ) ELSE IF not x%item:.jpeg=%==x%item% (
REM     chafa -f sixel %1
REM ) ELSE IF not x%item:.png=%==x%item% (
REM     chafa -f sixel %1
REM ) ELSE IF not x%item:.webp=%==x%item% (
REM     chafa -f sixel %1
REM ) ELSE (
REM 	bat --color=always --line-range=:200 %1
REM )
