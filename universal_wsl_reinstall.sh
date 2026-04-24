#!/bin/bash

# --- LOGGING SETUP ---
LOGFILE="reinstall_universal_$(date +%Y%m%d_%H%M).txt"
exec > >(tee -a "$LOGFILE") 2>&1

echo "------------------------------------------------"
echo "Starting Clean Reinstall: Native Debian Trixie"
echo "Target: Universal Hardware | Flatpak & Emulation"
echo "------------------------------------------------"

# 1. Pre-flight & Core Firmware
sudo apt update && sudo apt install -y ca-certificates wget curl gnupg2 pciutils firmware-linux nvidia-detect
sudo update-ca-certificates

set -e

# 2. Repository Setup (Debian Trixie + 32-bit Architecture)
echo "Setting up Trixie Repositories (Main/Contrib/Non-Free/Firmware)..."
sudo dpkg --add-architecture i386
sudo tee /etc/apt/sources.list <<EOT
deb http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware
deb http://deb.debian.org/debian/ trixie-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
EOT

# WineHQ Key
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

# 3. Flatpak & Flatseal Setup
echo "Configuring Flatpak, Flathub, and Flatseal..."
sudo apt install -y flatpak
# Adding --user and updating ensures the repository index is actually downloaded
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak update -y

echo "Installing Kodi via Flatpak..."
# Note: Corrected Kodi ID to tv.kodi.Kodi
flatpak install -y flathub tv.kodi.Kodi


# 4. The Universal Hardware Trick (NVIDIA Detection)
echo "Analyzing GPU hardware..."
if lspci | grep -i nvidia > /dev/null; then
    echo "NVIDIA GPU detected. Installing proprietary drivers & 32-bit GLX..."
    sudo apt install -y nvidia-driver libgl1-nvidia-glvnd-glx:i386 nvidia-vulkan-icd nvidia-vulkan-icd:i386
else
    echo "Using Open Source / Intel / AMD stack."
fi

# 5. Core Software & Emulator Installation
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
    fuse libfuse2t64 dbus-x11 xdg-desktop-portal-gtk \
    libgl1-mesa-dri libgl1-mesa-dri:i386 \
    mesa-vulkan-drivers mesa-vulkan-drivers:i386 \
    intel-media-va-driver-non-free \
    winehq-staging retroarch dolphin-emu \
    antimicrox \
    zram-tools python3-pil python3-lxml git usbutils \
    pipewire-audio-client-libraries libpulse0 alsa-utils pulseaudio-utils 

# 6. Other AppImages
echo "Organizing Emulators..."
mkdir -p ~/Applications
[ -f PPSSPP-*.AppImage ] && mv PPSSPP-*.AppImage ~/Applications/ppsspp.AppImage
[ -f xemu-*.AppImage ] && mv xemu-*.AppImage ~/Applications/xemu.AppImage
chmod +x ~/Applications/*.AppImage

# 7. USB Tools (Ventoy for Local PC)
# Note: Ventoy must be run from the PC that the user is putting ISOs on.
echo "Downloading latest Ventoy for Linux..."
mkdir -p ~/usb-tools && cd ~/usb-tools
VENTOY_URL=$(curl -s https://api.github.com/repos/ventoy/Ventoy/releases/latest | grep "browser_download_url.*linux.tar.gz" | cut -d '"' -f 4)
wget --no-check-certificate -O ventoy.tar.gz "$VENTOY_URL"
tar -xvf ventoy.tar.gz
rm ventoy.tar.gz
cd ~

# 8. Cleanup & Final Polish
echo "Cleaning up installer files..."
sudo apt autoremove -y
sudo apt autoclean
rm -f *.deb

echo "------------------------------------------------"
echo "Setup Complete!"
echo "NOTE: Ventoy is extracted in ~/usb-tools."
echo "IMPORTANT: Please REBOOT to activate drivers and permissions."
echo "------------------------------------------------"