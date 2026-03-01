#!/bin/bash

# Log everything to a file as well as the screen
LOGFILE="reinstall_log.txt"
exec > >(tee -a "$LOGFILE") 2>&1

echo "------------------------------------------------"
echo "Starting WSL2 (Ryzen 3) Reinstallation at $(date)"
echo "------------------------------------------------"

# Ensure script stops if a critical command fails
set -e

# 1. Enable 32-bit architecture (Essential for Steam and Emulators)
sudo dpkg --add-architecture i386
sudo apt update && sudo apt upgrade -y

# 2. Install APT Packages (Filtered for Ryzen 3 & WSL2 compatibility)
# Removed: grub, intel-microcode, firmware-iwlwifi, intel-media-va-driver
# Added: mesa-va-drivers and mesa-vulkan-drivers for Ryzen/AMD graphics
sudo apt install -y \
  adduser antimicro apt apt-listchanges apt-utils base-files base-passwd \
  bash bash-completion bind9-dnsutils bind9-host bsdutils busybox bzip2 \
  ca-certificates codium console-setup coreutils cpio curl dash debconf \
  debconf-i18n debian-archive-keyring debian-faq debianutils diffutils \
  dmidecode doc-debian dosfstools dpkg e2fsprogs file findutils flatpak \
  fontconfig fonts-liberation fuse gcc-14-base gddrescue gdebi geany \
  gettext-base grep groff-base gzip hostname ifupdown inetutils-telnet \
  init init-system-helpers iproute2 iputils-ping keyboard-configuration \
  kmod kpartx krb5-locales laptop-detect less locales login login.defs \
  logrotate logsave lsof lvm2 man-db manpages mawk media-types mesa-utils \
  mesa-va-drivers mesa-va-drivers:i386 mesa-vulkan-drivers:i386 \
  libgl1-mesa-dri:i386 libgl1-mesa-glx:i386 mount nano ncurses-base \
  ncurses-bin ncurses-term netbase netcat-traditional nftables \
  openssh-client openssl passwd pciutils perl perl-base procps python3 \
  readline-common reportbug sed sensible-utils smartmontools sqv \
  systemd systemd-sysv systemd-timesyncd sysvinit-utils tar \
  traceroute tzdata ucf udev usbutils util-linux util-linux-extra \
  va-driver-all:i386 vim-common vim-tiny wamerican wget whiptail \
  wireless-tools wpasupplicant wtmpdb xdg-desktop-portal \
  xdg-desktop-portal-gtk xdg-utils xterm xz-utils zenity zlib1g \
  zram-tools zstd

# 3. Installing ALL your Flatpaks (Emulators, IDEs, and Launchers)
echo 'Setting up Flatpak...'
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub \
  com.github.Rosalie241.RMG \
  com.github.tchx84.Flatseal \
  com.google.AndroidStudio \
  com.valvesoftware.Steam \
  io.github.ebonjaeger.bluejay \
  net.davidotek.pupgui2 \
  net.lutris.Lutris \
  org.DolphinEmu.dolphin-emu \
  org.desmume.DeSmuME \
  org.libretro.RetroArch \
  org.ppsspp.PPSSPP \
  tv.kodi.Kodi

# 4. Restoring .bashrc
echo 'Writing .bashrc...'
cat << 'BASHRC_EOF' > ~/.bashrc
# [Your original .bashrc content remains exactly the same]
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
BASHRC_EOF

# 5. Local .deb Files (Excluding Chrome if you prefer the Windows browser)
# Note: Sunshine on WSL2 requires specialized network configuration
sudo dpkg -i sunshine-debian-trixie-amd64.deb || sudo apt install -f -y

echo "------------------------------------------------"
echo "WSL2 Ryzen 3 Reinstallation Complete!"
echo "------------------------------------------------"
