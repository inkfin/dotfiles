@echo off
set "PYTHONDONTWRITEBYTECODE=1"
set "PYTHONPATH=%~dp0..\share;%PYTHONPATH%"
python -m apptools %*
