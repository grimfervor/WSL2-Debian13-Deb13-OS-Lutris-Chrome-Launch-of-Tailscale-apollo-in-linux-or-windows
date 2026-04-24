@echo off
:: Launches Duckstation via WSL Debian with GUI support
wsl.exe -d Debian -e sh -c "flatpak run org.duckstation.DuckStation"