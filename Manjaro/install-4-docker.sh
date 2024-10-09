#/bin/sh
./update.sh

sudo pacman -S --noconfirm docker

sudo usermod -aG docker $USER

sudo systemctl start docker.service
sudo systemctl enable docker.service

sudo docker run hello-world
