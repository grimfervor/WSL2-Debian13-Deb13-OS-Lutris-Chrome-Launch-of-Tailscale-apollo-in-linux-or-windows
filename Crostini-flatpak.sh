#!/bin/bash

# Update package lists and install Flatpak
echo "Installing Flatpak and configuring Flathub..."
sudo apt update
sudo apt install -y flatpak

# Add the Flathub repository
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo [cite: 1]

# Install the requested emulators and apps
echo "Installing applications..."
sudo flatpak install -y flathub org.desmume.DeSmuME [cite: 1]
sudo flatpak install -y flathub com.github.Rosalie241.RMG [cite: 1]
sudo flatpak install -y flathub org.DolphinEmu.dolphin-emu [cite: 1]
sudo flatpak install -y flathub org.ppsspp.PPSSPP [cite: 1]
sudo flatpak install -y flathub tv.kodi.Kodi [cite: 1]
sudo flatpak install -y flathub net.lutris.Lutris 
sudo flatpak install -y flathub io.mgba.mGBA 
sudo flatpak install -y flathub com.github.tchx84.Flatseal 

echo "Installation process complete."
echo "Note: You may need to restart your Linux container for apps to appear in the launcher."
read -p "Press [Enter] to finish..." [cite: 3]