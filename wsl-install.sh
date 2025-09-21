#!/bin/sh

sudo add-apt-repository ppa:wslutilities/wslu
sudo apt update
sudo apt install wslu
echo "export BROWSER=wslview" >> $HOME/.zshrc

# wsl --install Ubuntu-24.04
echo '##################'
echo '# Install gh-cli #'
echo '##################'
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
&& sudo mkdir -p -m 755 /etc/apt/keyrings \
&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install -y gh

gh auth login 

echo '##########################'
echo '# Setup gpg from Windows #'
echo '##########################'
# Run on Windows
gpg --armor --export-secret-keys <YourKeyID> > C:\Users\<YourUser>\private.key
# Run on WSL
cp /mnt/c/Users/<YourUser>/private.key ~/
gpg --import ~/private.key
gpg --edit-key <YourKeyID>
# In gpg interactive
trust
# pick 5 = ultimate
quit

# Run on WSL
git config --global gpg.program gpg
git config --global user.signingkey <YourKeyID>
git config --global commit.gpgsign true

# Alternatic
# Install npiperelay on Windows.
# In WSL, create a Unix socket that forwards to the Windows named pipe:
#socat UNIX-LISTEN:$HOME/.gnupg/S.gpg-agent,fork EXEC:"npiperelay.exe -ei -s //./pipe/S.gpg-agent"
# Point WSL GPG to that socket.

# cp ~/.gitconfig
# configure gpg

# Install WSL plugin in VSCode

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

