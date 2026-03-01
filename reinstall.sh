#!/bin/bash

# Log everything to a file as well as the screen
LOGFILE="reinstall_log.txt"
exec > >(tee -a "$LOGFILE") 2>&1

echo "------------------------------------------------"
echo "Starting System Reinstallation at $(date)"
echo "------------------------------------------------"

# Ensure script stops if a critical command fails
set -e

# Update system first
sudo apt update && sudo apt upgrade -y

# --- Adding Repositories ---

# --- Installing APT Packages ---
sudo apt update
sudo apt install -y adduser antimicro apt apt-listchanges apt-utils base-files base-passwd bash bash-completion bind9-dnsutils bind9-host blueman bluez bsdutils busybox bzip2 ca-certificates codium console-setup coreutils cpio cron cron-daemon-common curl curseforge dash dbus debconf debconf-i18n debian-archive-keyring debian-faq debianutils desmume dhcpcd-base diffutils dmidecode doc-debian dosfstools dpkg e2fsprogs eject fdisk file findutils firmware-intel-graphics firmware-iwlwifi flatpak fontconfig fonts-liberation fuse gcc-14-base gddrescue gdebi geany gettext-base gnome-disk-utility google-chrome-stable grep groff-base grub-common grub-efi-amd64 gzip hostname i965-va-driver:i386 ifupdown inetutils-telnet init init-system-helpers initramfs-tools installation-report intel-media-va-driver:i386 intel-microcode iproute2 iputils-ping keyboard-configuration kmod kpartx krb5-locales laptop-detect less linux-sysctl-defaults locales login login.defs logrotate logsave lsof lvm2 man-db manpages mawk media-types mesa-utils mesa-va-drivers mesa-va-drivers:i386 mesa-vulkan-drivers:i386 mount nano ncurses-base ncurses-bin ncurses-term netbase netcat-traditional nftables openssh-client openssl-provider-legacy os-prober passwd pciutils perl perl-base procps python3 readline-common reportbug sed sensible-utils shim-signed smartmontools snap sqv steam-launcher steam-libs-amd64 systemd systemd-sysv systemd-timesyncd sysvinit-utils tar task-desktop task-english task-laptop task-xfce-desktop tasksel testdisk tlauncher-linux-installer traceroute transmission-gtk tzdata ucf udev usbutils util-linux util-linux-extra va-driver-all:i386 vim-common vim-tiny wamerican wget whiptail winehq-staging wireless-tools wpasupplicant wtmpdb xboxdrv xdg-desktop-portal xdg-desktop-portal-gtk xdg-utils xterm xz-utils zenity zlib1g zram-tools zstd 

# --- Installing Flatpaks ---
echo 'Setting up Flatpak...'
sudo apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.github.Rosalie241.RMG com.github.tchx84.Flatseal com.google.AndroidStudio com.valvesoftware.Steam io.github.ebonjaeger.bluejay net.davidotek.pupgui2 net.lutris.Lutris org.DolphinEmu.dolphin-emu org.desmume.DeSmuME org.libretro.RetroArch org.ppsspp.PPSSPP tv.kodi.Kodi 

# --- Restoring Sanitized .bashrc ---
echo 'Writing .bashrc (API keys and passwords removed)...'
cat << 'BASHRC_EOF' > ~/.bashrc
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

BASHRC_EOF

# --- Installing Local .deb Files ---
sudo dpkg -i google-chrome-stable_current_amd64.deb sunshine-debian-trixie-amd64.deb  || sudo apt install -f -y
echo "------------------------------------------------"
echo "Reinstallation Complete!"
echo "Please manually restore any API keys or passwords to your .bashrc."
echo "A log of this session is saved in reinstall_log.txt"
echo "------------------------------------------------"
