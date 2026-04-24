#!/bin/bash

# 1. Update package lists and install Flatpak
echo "Updating system and installing Flatpak..."
sudo apt update && sudo apt install -y flatpak

# 2. Add the Flathub repository (Forced to System to avoid prompts)
echo "Adding Flathub repository..."
sudo flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 3. Install all applications
echo "Installing applications..."
# Added -y and --noninteractive for a smooth script run
sudo flatpak install --system -y flathub \
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
    org.libretro.RetroArch \
    com.fceux.FCEUX \
    org.duckstation.DuckStation \
    com.github.tchx84.Flatseal

# 4. First-Time Launch Sequence (WSLg Support)
echo "Initializing applications for first-time use..."
export DISPLAY=:0

# Updated List: Replaced org.bannister.GenesisPlus with org.libretro.RetroArch
apps=(
    "org.desmume.DeSmuME"
    "com.github.Rosalie241.RMG"
    "org.DolphinEmu.dolphin-emu"
    "org.ppsspp.PPSSPP"
    "tv.kodi.Kodi"
    "net.lutris.Lutris"
    "io.mgba.mGBA"
    "app.xemu.xemu"
    "net.pcsx2.PCSX2"
    "com.snes9x.Snes9x"
    "org.libretro.RetroArch"
    "com.fceux.FCEUX"
    "org.duckstation.DuckStation"
)

for app in "${apps[@]}"; do
    echo "Launching $app..."
    # Launch in background, redirecting output to null to keep the terminal clean
    flatpak run $app > /dev/null 2>&1 & 
    
    # Wait for the app to generate config files
    sleep 8
    
    # Kill the process
    echo "Closing $app..."
    pkill -f $app || sudo pkill -9 -f $app
done

echo "Installation and Initialization complete."