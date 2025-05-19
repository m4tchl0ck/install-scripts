#!/bin/sh

#cp ~/.giconfig
sudo add-apt-repository ppa:wslutilities/wslu
sudo apt update
sudo apt install wslu
echo "BROWSER=wslview" >> $HOME/.zshrc
# Podman
# https://github.com/containers/podman/releases/latest
wget https://github.com/containers/podman/releases/download/v4.9.1/podman-remote-static-linux_amd64.tar.gz
sudo tar -C /usr/local -xzf podman-remote-static-linux_amd64.tar.gz
export PATH="$PATH:/usr/local/bin"
alias podman='podman-remote-static-linux_amd64'
podman system connection add --default podman-machine-default-root unix:///mnt/wsl/podman-sockets/podman-machine-default/podman-root.sock
# rootless
podman system connection add --default podman-machine-default-user unix:///mnt/wsl/podman-sockets/podman-machine-default/podman-user.sock
sudo usermod --append --groups 10 $(whoami)
#check
podman run quay.io/podman/hello

