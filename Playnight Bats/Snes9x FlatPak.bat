@echo off
:: Launches Snes9x via WSL Debian with GUI support
wsl.exe -d Debian -e sh -c "flatpak run com.snes9x.Snes9x"