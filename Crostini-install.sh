#!/bin/bash

# --- LOGGING SETUP ---
LOGFILE="setup_crostini_trixie_$(date +%Y%m%d_%H%M).txt"
exec > >(tee -a "$LOGFILE") 2>&1

echo "------------------------------------------------"
echo "Starting Chromebook Linux Setup: Debian Trixie"
echo "Environment: Crostini Container | OS: ChromeOS"
echo "------------------------------------------------"

# 1. Pre-flight & Core Tools
# Note: Hardware firmware (firmware-linux) is removed as ChromeOS manages firmware.
sudo apt update && sudo apt install -y ca-certificates wget curl gnupg2
sudo update-ca-certificates

set -e

# 2. Repository Setup (Debian Trixie + 32-bit Architecture)
echo "Setting up Trixie Repositories..."
sudo dpkg --add-architecture i386
sudo tee /etc/apt/sources.list <<EOT
deb http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware
deb http://deb.debian.org/debian/ trixie-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
EOT

# WineHQ Key & Repository Setup (Updated for Trixie)
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget --no-check-certificate -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

sudo tee /etc/apt/sources.list.d/winehq.sources <<EOT
Types: deb
URIs: https://dl.winehq.org/wine-builds/debian
Suites: trixie
Components: main
Architectures: amd64 i386
Signed-By: /etc/apt/keyrings/winehq-archive.key
EOT

sudo apt update

# 3. Flatpak & Global App Setup
echo "Configuring Flatpak and Flathub..."
sudo apt install -y flatpak
# On Chromebooks, we typically add Flathub globally for all container users
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "Installing Kodi, Lutris, and Flatseal..."
# Flatseal is highly recommended for Crostini to manage file permissions
flatpak install -y flathub tv.kodi.Kodi net.lutris.Lutris com.github.tchx84.Flatseal

# 4. Native Software & Emulation Suite
# Added 'libfuse2' specifically for AppImage compatibility in Crostini
# Removed hardware-specific drivers (NVIDIA/Intel) as they conflict with ChromeOS
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
    fuse libfuse2t64 dbus-x11 xdg-desktop-portal-gtk \
    winehq-staging retroarch dolphin-emu \
    git zram-tools pulseaudio-utils

# 5. AppImage Management
echo "Organizing AppImages in ~/Applications..."
mkdir -p ~/Applications
# Reminders: You must right-click USB files in ChromeOS and 'Share with Linux' first.
[ -f PPSSPP-*.AppImage ] && mv PPSSPP-*.AppImage ~/Applications/ppsspp.AppImage
[ -f xemu-*.AppImage ] && mv xemu-*.AppImage ~/Applications/xemu.AppImage
chmod +x ~/Applications/*.AppImage 2>/dev/null || true

# 6. Final Cleanup
echo "Cleaning up package cache..."
sudo apt autoremove -y
sudo apt autoclean

echo "------------------------------------------------"
echo "Crostini Setup Complete!"
echo "NOTE: To use USB devices (like controllers), you must"
echo "enable them in ChromeOS Settings > Developers > Linux."