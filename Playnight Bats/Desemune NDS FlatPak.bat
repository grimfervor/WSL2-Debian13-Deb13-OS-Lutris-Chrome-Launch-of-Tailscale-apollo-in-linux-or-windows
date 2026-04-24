@echo off
:: Launches DeSmuME via WSL Debian
wsl.exe -d Debian -e sh -c "flatpak run org.desmume.DeSmuME"