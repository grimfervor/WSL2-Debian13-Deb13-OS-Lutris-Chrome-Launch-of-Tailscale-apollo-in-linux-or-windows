#!/bin/bash

# The name of the script we are going to create
OUTPUT="reinstall.sh"

echo "Generating $OUTPUT..."

# 1. Start the script and define a log file
cat << 'EOF' > $OUTPUT
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
EOF

# 2. Capture Repositories (PPAs)
echo -e "\n# --- Adding Repositories ---" >> $OUTPUT
for ppa in $(grep -v '^#' /etc/apt/sources.list.d/* 2>/dev/null | grep -oP '(?<=ppa.launchpad.net/)[^/]+/[^/]+' | sort -u); do
    echo "sudo add-apt-repository -y ppa:$ppa" >> $OUTPUT
done

# 3. Capture APT Packages
echo -e "\n# --- Installing APT Packages ---" >> $OUTPUT
PACKAGES=$(apt-mark showmanual | grep -vE '^(lib|linux-image|python3-)' | tr '\n' ' ')
echo "sudo apt update" >> $OUTPUT
echo "sudo apt install -y $PACKAGES" >> $OUTPUT

# 4. Capture Flatpaks
echo -e "\n# --- Installing Flatpaks ---" >> $OUTPUT
FLATPAKS=$(flatpak list --app --columns=application 2>/dev/null | tail -n +1 | tr '\n' ' ')
if [ -n "$FLATPAKS" ]; then
    echo "echo 'Setting up Flatpak...'" >> $OUTPUT
    echo "sudo apt install -y flatpak" >> $OUTPUT
    echo "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo" >> $OUTPUT
    echo "flatpak install -y flathub $FLATPAKS" >> $OUTPUT
fi

# 5. Backup .bashrc (SANITIZED)
echo -e "\n# --- Restoring Sanitized .bashrc ---" >> $OUTPUT
echo "echo 'Writing .bashrc (API keys and passwords removed)...'" >> $OUTPUT
echo "cat << 'BASHRC_EOF' > ~/.bashrc" >> $OUTPUT

# This 'sed' command looks for lines containing secret-related words 
# and replaces the whole line with a placeholder.
sed -E 's/.*(PASSWORD|PASSWD|SECRET|TOKEN|API_KEY|AUTH_KEY).*/# [REMOVED FOR SECURITY]/' ~/.bashrc >> $OUTPUT

echo -e "\nBASHRC_EOF" >> $OUTPUT

# 6. Capture local .deb files from current folder
DEBS=$(ls *.deb 2>/dev/null | tr '\n' ' ')
if [ -n "$DEBS" ]; then
    echo -e "\n# --- Installing Local .deb Files ---" >> $OUTPUT
    echo "sudo dpkg -i $DEBS || sudo apt install -f -y" >> $OUTPUT
fi

# 7. Final Clean up
cat << 'EOF' >> $OUTPUT
echo "------------------------------------------------"
echo "Reinstallation Complete!"
echo "Please manually restore any API keys or passwords to your .bashrc."
echo "A log of this session is saved in reinstall_log.txt"
echo "------------------------------------------------"
EOF

chmod +x $OUTPUT
echo "Success! $OUTPUT has been generated with security filtering enabled."
