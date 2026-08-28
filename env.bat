@echo off
chcp 65001 >nul
cd /d "%~dp0"
set "PATH=%~dp0;%PATH%"
cmd /k "%~dp0_tools\startup.bat"
