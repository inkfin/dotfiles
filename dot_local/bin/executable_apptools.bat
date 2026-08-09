@echo off
set "PYTHONPATH=%~dp0..\share;%PYTHONPATH%"
python -m apptools %*
