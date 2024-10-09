#!/bin/sh

./update.sh

echo '###############'
echo '# Install zsh #'
echo '###############'
sudo pacman -S --noconfirm zsh

echo 'Set zsh as default shell'
chsh -s $(which zsh)


echo '#################'
echo '# Install tools #'
echo '#################'
sudo pacman -S --noconfirm bat
sudo pacman -S --noconfirm btop
# sudo pacman -S --noconfirm direnv
sudo pacman -S --noconfirm jless
sudo pacman -S --noconfirm jq
sudo pacman -S --noconfirm ripgrep
sudo pacman -S --noconfirm tmux
sudo pacman -S --noconfirm eza
sudo pacman -S --noconfirm fzf
sudo pacman -S --noconfirm mc

sudo pacman -S --noconfirm neovim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# GPG
echo '###############'
echo '# Install gpg #'
echo '###############'
sudo pacman -S --noconfirm gnupg socat

# dotfiles
echo '###################'
echo '# Install chezmoi #'
echo '###################'
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
echo 'export PATH=$HOME/.local/bin:$PATH' >> $HOME/.zshrc

echo '#################'
echo '# Install brave #'
echo '#################'
sudo pacman -S --noconfirm brave-browser

echo '################'
echo '# Install brew #'
echo '################'
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/adrian/.zshrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo '###############'
echo '# Install yay #'
echo '###############'
mkdir -p $HOME/tools
cd $HOME/tools
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

echo '#################'
echo '# Install fonts #'
echo '#################'
yay -S --noconfirm ttf-terminus-nerd

echo '################'
echo '# Install edge #'
echo '################'
yay -S --noconfirm microsoft-edge-dev-bin

