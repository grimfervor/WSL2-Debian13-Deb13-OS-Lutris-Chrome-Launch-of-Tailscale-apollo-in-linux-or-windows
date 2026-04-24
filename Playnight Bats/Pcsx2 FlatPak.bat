@echo off
:: Launches Pcsx2 via WSL Debian with GUI support
wsl.exe -d Debian -e sh -c "flatpak run net.pcsx2.PCSX2"