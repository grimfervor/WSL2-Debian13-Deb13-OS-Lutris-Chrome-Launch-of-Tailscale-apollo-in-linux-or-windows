https://archive.org/details/iagl-kit-unzip-to-sdcard

1a.Put Debian On OLD computers w/o Virtualization... 
dos2unix Debian-OS-Reinstall.sh
sudo chmod +x Debian-OS-Reinstall.sh


1b.WSL is more complete! Put wsl folder and wsl_bkup.tar to root of usb 
Type  wsl --import debian D:\wsl\debian D:\wsl_backup.tar
Then To Be Bigshot Grimf-user sudo-1234
wsl --manage Debian --set-default-user grimf

dos2unix universal_wsl_reinstall.sh
sudo chmod +X universal_wsl_reinstall.sh
Pass-1234

2.# Run as Administrator - This does everything automatically
irm https://sunshine-aio.com/script.ps1 | ie

sudo apt install gdebi
sudo gdebi lutris_0.5.22_all.deb

After Sunshine AIO link install from powershell in pdf Run
Must do https://localhost:47990 And setup Pass first

mkdir -p ~/tools && cd ~/tools
git clone https://github.com/Arbitrate3280/LutrisToSunshine.git
cd LutrisToSunshine
python3 lutristosunshine.py --all
sudo apt install libfuse2