#!/bin/sh

echo '###########'
echo '# Upgrade #'
echo '###########'
sudo apt update && sudo apt upgrade -y

echo '###############'
echo '# Install zsh #'
echo '###############'
sudo apt install -y zsh

echo 'Set zsh as default shell'
chsh -s $(which zsh)


echo '#################'
echo '# Install tools #'
echo '#################'
sudo apt-get install -y bat
sudo apt-get install -y btop
# sudo apt-get install -y direnv
sudo apt-get install -y jless
sudo apt-get install -y jq
sudo apt-get install -y neovim
sudo apt-get install -y ripgrep
sudo apt-get install -y tmux

sudo apt install -y eza
sudo apt install -y fzf

# GPG
echo '###############'
echo '# Install gpg #'
echo '###############'
sudo apt-get install -y gnupg2 gnupg-agent socat

# dotfiles
echo '###################'
echo '# Install chezmoi #'
echo '###################'
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin


echo 'export PATH=$HOME/.local/bin:$PATH' >> $HOME/.zshrc
