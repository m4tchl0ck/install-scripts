#!/bin/sh

./update.sh

echo '#################'
echo '# Install tools #'
echo '#################'
brew install bat
brew install btop
brew install direnv
brew install jless
brew install jq
brew install ripgrep
brew install --cask kitty
brew install tmux
brew install eza
brew install fzf
brew install mc
brew install wget

brew install neovim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# GPG
echo '###############'
echo '# Install gpg #'
echo '###############'
brew install gnupg socat

# dotfiles
echo '###################'
echo '# Install chezmoi #'
echo '###################'
brew install chezmoi

echo '#################'
echo '# Install brave #'
echo '#################'
brew install brave-browser

echo '#################'
echo '# Install fonts #'
echo '#################'
brew install --cask font-terminess-ttf-nerd-font


echo '################'
echo '# Install edge #'
echo '################'
brew install --cask microsoft-edge


brew install --cask miro
brew install --cask obsidian      
brew install --cask spotify

brew install pinentry-mac
brew install --cask hammerspoon
brew install --cask wins
brew install --cask alt-tab
brew install --cask shottr

brew install --cask chatgpt
brew install --cask discord
brew install --cask bitwarden

brew install --cask openvpn-connect

brew install --cask surfshark
