#!/bin/bash

# --- LOGGING SETUP ---
LOGFILE="reinstall_trixie_$(date +%Y%m%d_%H%M).txt"
exec > >(tee -a "$LOGFILE") 2>&1

echo "------------------------------------------------"
echo "Starting Native Reinstall: Debian Trixie (Testing)"
echo "Environment: Full OS Reinstall | Hardware: Universal"
echo "------------------------------------------------"

# 1. Pre-flight & Core Firmware
# Ensures the system can handle HTTPS and identify hardware immediately
sudo apt update && sudo apt install -y ca-certificates wget curl gnupg2 pciutils firmware-linux nvidia-detect
sudo update-ca-certificates

set -e

# 2. Repository Setup (Debian Trixie + 32-bit Architecture)
# Standardizes sources for Trixie including the non-free-firmware component
echo "Setting up Trixie Repositories (Main/Contrib/Non-Free/Firmware)..."
sudo dpkg --add-architecture i386
sudo tee /etc/apt/sources.list <<EOT
deb http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware
deb http://deb.debian.org/debian/ trixie-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
EOT

# WineHQ Key & Repository Setup
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
# Adding the remote and updating ensures the app index is ready
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak update -y

echo "Installing Kodi, Lutris, and Flatseal..."
# Fixed Kodi ID to the current Flathub standard: tv.kodi.Kodi
flatpak install -y flathub tv.kodi.Kodi
flatpak install -y flathub net.lutris.Lutris
flatpak install -y flathub com.github.tchx84.Flatseal

# 4. Hardware-Specific Driver Logic
echo "Analyzing GPU hardware..."
if lspci | grep -i nvidia > /dev/null; then
    echo "NVIDIA GPU detected. Installing proprietary drivers & 32-bit GLX..."
    sudo apt install -y nvidia-driver libgl1-nvidia-glvnd-glx:i386 nvidia-vulkan-icd nvidia-vulkan-icd:i386
else
    echo "Using Open Source / Intel / AMD graphics stack."
    sudo apt install -y mesa-vulkan-drivers mesa-vulkan-drivers:i386 intel-media-va-driver-non-free
fi

# 5. Native Software & Emulation Suite
# Includes required libraries for AppImages and sound server components
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
    fuse libfuse2t64 dbus-x11 xdg-desktop-portal-gtk \
    libgl1-mesa-dri libgl1-mesa-dri:i386 \
    winehq-staging retroarch dolphin-emu mupen64plus-ui-console \
    antimicrox zram-tools git usbutils \
    pipewire-audio-client-libraries libpulse0 alsa-utils pulseaudio-utils

# 6. AppImage Management
echo "Organizing AppImages in ~/Applications..."
mkdir -p ~/Applications
# Safely moves common emulators if they exist in the current directory
[ -f PPSSPP-*.AppImage ] && mv PPSSPP-*.AppImage ~/Applications/ppsspp.AppImage
[ -f xemu-*.AppImage ] && mv xemu-*.AppImage ~/Applications/xemu.AppImage
chmod +x ~/Applications/*.AppImage 2>/dev/null || true

# 7. Local USB Tools (Ventoy)
# IMPORTANT: Ventoy must be run from the PC that the user is putting ISOs on
echo "Downloading Ventoy for local USB creation..."
mkdir -p ~/usb-tools && cd ~/usb-tools
VENTOY_URL=$(curl -s https://api.github.com/repos/ventoy/Ventoy/releases/latest | grep "browser_download_url.*linux.tar.gz" | cut -d '"' -f 4)
wget --no-check-certificate -O ventoy.tar.gz "$VENTOY_URL"
tar -xvf ventoy.tar.gz
rm ventoy.tar.gz
cd ~

# 8. Final Cleanup
echo "Cleaning up package cache..."
sudo apt autoremove -y
sudo apt autoclean
rm -f *.deb

echo "------------------------------------------------"
echo "Reinstall Script Complete!"
echo "Ventoy is ready in: ~/usb-tools"
echo "IMPORTANT: Restart your computer to apply drivers."
echo "------------------------------------------------"