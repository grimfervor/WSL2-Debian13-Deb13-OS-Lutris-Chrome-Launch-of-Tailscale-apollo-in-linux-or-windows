@echo off
:: Launches Flatseal via WSL Debian using the Flatpak runner
wsl.exe -d Debian -e sh -c "flatpak run com.github.tchx84.Flatseal"