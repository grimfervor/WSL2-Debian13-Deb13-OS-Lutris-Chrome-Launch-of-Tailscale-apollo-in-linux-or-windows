@echo off
:: Launches Genesis Plus via WSL Debian with GUI support
wsl.exe -d Debian -e sh -c "flatpak run org.bannister.GenesisPlus"