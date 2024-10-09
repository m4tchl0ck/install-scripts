#/bin/sh

# virtualbox guest additions (https://wiki.manjaro.org/index.php/VirtualBox)
# mhwd-kernel -l
# mhwd-kernel -li

# sudo pacman -Syu virtualbox-guest-utils
# sudo systemctl enable --now vboxservice.service
# sudo usermod -aG vboxsf ${USER}
# sudo mkdir /media
# sudo chmod 755 /media

# https://gist.github.com/estorgio/0c76e29c0439e683caca694f338d4003
sudo mkdir /media/cdrom
sudo mount -t iso9660 /dev/cdrom /media/cdrom

sudo /media/cdrom/./VBoxLinuxAdditions.run

sudo shutdown -r now

echo "shared	$HOME/shared	vboxsf	defaults	0	0" | sudo tee -a /etc/fstab

echo "vboxsf" | sudo tee -a /etc/modules
