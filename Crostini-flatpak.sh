#!/bin/bash

# Update package lists and install Flatpak
echo "Installing Flatpak and configuring Flathub..."
sudo apt update
sudo apt install -y flatpak

# Add the Flathub repository
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install the requested emulators and apps
echo "Installing applications..."
sudo flatpak install -y flathub \
    org.desmume.DeSmuME \
    com.github.Rosalie241.RMG \
    org.DolphinEmu.dolphin-emu \
    org.ppsspp.PPSSPP \
    tv.kodi.Kodi \
    net.lutris.Lutris \
    io.mgba.mGBA \
    app.xemu.xemu \
    net.pcsx2.PCSX2 \
    com.snes9x.Snes9x \
    org.bannister.GenesisPlus \
    com.fceux.FCEUX \
    org.duckstation.DuckStation \
    com.github.tchx84.Flatseal

echo "Installation process complete."
echo "Note: You may need to restart your Linux container for apps to appear in the launcher."
read -p "Press [Enter] to finish..."