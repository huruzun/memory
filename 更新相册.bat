@echo off
cd /d "%~dp0"
echo Running update script...
powershell -NoProfile -ExecutionPolicy Bypass -File "tools\deploy.ps1"
if errorlevel 1 (
    echo.
    echo Script failed. Please check the error messages above.
    pause
) else (
    echo.
    echo Done.
    timeout /t 5
)
