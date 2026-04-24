@echo off
:: Define the directory path
set "GAME_DIR=C:\Users\grimf\Saved Games\Crosstini-WSL-Deb13-PlayNight-To-Android\Power Rangers Legend-Beast Morph v2"

:: Change to the game directory (the /d switch handles drive changes if needed)
cd /d "%GAME_DIR%"

:: Launch TLauncher
start "" javaw -jar "TLauncher.jar"

exit