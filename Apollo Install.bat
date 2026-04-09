@echo off
:: Check if WinGet is installed
winget --version >nul 2>&1
if %errorlevel% neq 0 (
    echo WinGet not found. Attempting to install...
    powershell -Command "Install-Module -Name Microsoft.WinGet.Client -Force -AllowClobber"
) else (
    echo WinGet is already installed.
)

:: Install Apollo
echo Installing Apollo...
winget install --id ClassicOldSong.Apollo --silent --accept-package-agreements --accept-source-agreements

pause
