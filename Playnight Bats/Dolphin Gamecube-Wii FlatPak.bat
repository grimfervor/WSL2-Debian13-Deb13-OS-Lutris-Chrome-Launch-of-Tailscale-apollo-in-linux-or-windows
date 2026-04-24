@echo off
:: Launches DolphinEmu via WSL Debian
wsl.exe -d Debian -e sh -c "flatpak run org.DolphinEmu.dolphin-emu"