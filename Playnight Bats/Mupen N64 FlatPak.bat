@echo off
:: Launches Mupen via WSL Debian with GUI support
wsl.exe -d Debian -e sh -c "flatpak run com.github.Rosalie241.RMG"