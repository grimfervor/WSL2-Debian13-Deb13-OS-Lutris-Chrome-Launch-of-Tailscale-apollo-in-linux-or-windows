@echo off
echo Installing Flatpak applications in WSL (Debian)...

:: Ensure Flatpak is installed and Flathub is added first
wsl.exe -d Debian -e sh -c "sudo apt update && sudo apt install -y flatpak && sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"

:: Install the requested emulators and apps
wsl.exe -d Debian -e sh -c "flatpak install -y flathub org.desmume.DeSmuME"
wsl.exe -d Debian -e sh -c "flatpak install -y flathub com.github.Rosalie241.RMG"
wsl.exe -d Debian -e sh -c "flatpak install -y flathub org.DolphinEmu.dolphin-emu"
wsl.exe -d Debian -e sh -c "flatpak install -y flathub org.ppsspp.PPSSPP"
wsl.exe -d Debian -e sh -c "flatpak install -y flathub tv.kodi.Kodi"
wsl.exe -d Debian -e sh -c "flatpak install -y flathub net.lutris.Lutris"
wsl.exe -d Debian -e sh -c "flatpak install -y flathub io.mgba.mGBA"
wsl.exe -d Debian -e sh -c "flatpak install -y flathub com.github.tchx84.Flatseal"

echo Installation process complete.
pause