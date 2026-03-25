#!/bin/bash

# --- LOGGING SETUP ---
LOGFILE="reinstall_native_final_$(date +%Y%m%d_%H%M).txt"
exec > >(tee -a "$LOGFILE") 2>&1

echo "------------------------------------------------"
echo "Starting Clean Reinstall: Native Debian Trixie"
echo "Target: Universal Hardware + NVIDIA + Cleanup"
echo "------------------------------------------------"

# 1. Pre-flight & Firmware
# Native Debian requires non-free-firmware for WiFi/GPU stability
sudo apt update && sudo apt install -y ca-certificates wget curl gnupg2 firmware-linux nvidia-detect
sudo update-ca-certificates

set -e

# 2. Repository Setup (Debian Trixie + 32-bit Architecture)
echo "Setting up Trixie Repositories (Main/Contrib/Non-Free)..."
sudo dpkg --add-architecture i386
sudo tee /etc/apt/sources.list <<EOT
deb http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware
deb http://deb.debian.org/debian/ trixie-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
EOT

# WineHQ Key (Staging branch for latest gaming fixes)
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

# 3. Automated NVIDIA Driver Installation
echo "Checking for NVIDIA hardware..."
if lspci | grep -i nvidia > /dev/null; then
    echo "NVIDIA GPU detected. Installing proprietary drivers & 32-bit support..."
    sudo apt install -y nvidia-driver libgl1-nvidia-glvnd-glx:i386 nvidia-vulkan-icd nvidia-vulkan-icd:i386
else
    echo "No NVIDIA GPU found. Skipping proprietary drivers."
fi

# 4. Generalized Hardware Drivers & Core Software
echo "Installing System Dependencies & Open-Source Drivers..."
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
    fuse libfuse2t64 dbus-x11 xdg-desktop-portal-gtk \
    libgl1-mesa-dri libgl1-mesa-dri:i386 \
    mesa-vulkan-drivers mesa-vulkan-drivers:i386 \
    intel-media-va-driver-non-free \
    winehq-staging retroarch dolphin-emu kodi mupen64plus-ui-console \
    zram-tools python3-pil python3-lxml git pciutils usbutils \
    pipewire-audio-client-libraries libpulse0 alsa-utils pulseaudio-utils

# 5. Lutris 0.5.22 Installation
echo "Installing Lutris 0.5.22..."
wget --no-check-certificate https://github.com/lutris/lutris/releases/download/v0.5.22/lutris_0.5.22_all.deb
sudo apt install -y ./lutris_0.5.22_all.deb
rm lutris_0.5.22_all.deb

# 6. Sunshine AppImage Setup
echo "Setting up Sunshine (Native Mode)..."
mkdir -p ~/Applications
[ -f sunshine.AppImage ] && mv sunshine.AppImage ~/Applications/
chmod +x ~/Applications/sunshine.AppImage

# Hardware Permissions for Sunshine (Encoders & Input)
sudo setcap cap_sys_admin+p ~/Applications/sunshine.AppImage
echo 'KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"' | \
sudo tee /etc/udev/rules.d/60-sunshine.rules
sudo usermod -aG input,video,render $USER

# Register Sunshine
~/Applications/sunshine.AppImage --install

# 7. Other Emulators
echo "Organizing AppImages..."
[ -f PPSSPP-*.AppImage ] && mv PPSSPP-*.AppImage ~/Applications/ppsspp.AppImage
[ -f xemu-*.AppImage ] && mv xemu-*.AppImage ~/Applications/xemu.AppImage
chmod +x ~/Applications/*.AppImage

# 8. USB Tools (Ventoy)
# Note: Executed on the local PC for ISO management
echo "Downloading latest Ventoy for Linux..."
mkdir -p ~/usb-tools && cd ~/usb-tools
VENTOY_URL=$(curl -s https://api.github.com/repos/ventoy/Ventoy/releases/latest | grep "browser_download_url.*linux.tar.gz" | cut -d '"' -f 4)
wget --no-check-certificate -O ventoy.tar.gz "$VENTOY_URL"
tar -xvf ventoy.tar.gz
rm ventoy.tar.gz
cd ~

# 9. Final Cleanup & Housekeeping
echo "------------------------------------------------"
echo "Performing Final Cleanup..."
echo "------------------------------------------------"

# A. System-level cleanup
sudo apt autoremove -y
sudo apt autoclean

# B. Remove temporary download files
rm -f *.deb

# C. Optional: User Config Purge (Commented out for safety)
# Uncomment the lines below if you want to wipe ALL settings for these apps
# echo "Purging old application configurations..."
# rm -rf ~/.config/lutris ~/.local/share/lutris
# rm -rf ~/.config/retroarch ~/.config/dolphin-emu
# rm -rf ~/.wine

echo "------------------------------------------------"
echo "Setup Complete!"
echo "IMPORTANT: Restart your PC to apply NVIDIA drivers,"
echo "PipeWire updates, and user group permissions."
echo "------------------------------------------------"