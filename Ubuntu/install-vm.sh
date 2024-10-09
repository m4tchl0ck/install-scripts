#/bin/sh

# https://gist.github.com/estorgio/0c76e29c0439e683caca694f338d4003
sudo mkdir /media/cdrom
sudo mount -t iso9660 /dev/cdrom /media/cdrom

sudo apt-get update
sudo apt-get install -y build-essential linux-headers-`uname -r`

sudo /media/cdrom/./VBoxLinuxAdditions.run

sudo shutdown -r now

echo "shared	$HOME/shared	vboxsf	defaults	0	0" | sudo tee -a /etc/fstab

echo "vboxsf" | sudo tee -a /etc/modules