#!/bin/sh

./update.sh

sudo pacman -S --noconfirm base-devel

# https://github.com/cli/cli/blob/trunk/docs/install_linux.md
echo '##################'
echo '# Install gh-cli #'
echo '##################'
sudo pacman -S --noconfirm github-cli

echo "##################"
echo "# Install dotnet #"
echo "##################"

wget https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh
chmod +x /tmp/dotnet-install.sh
/tmp/dotnet-install.sh --version latest
echo 'export PATH=$HOME/.dotnet:$PATH' >> $HOME/.zshrc
echo 'export DOTNET_ROOT=$HOME/.dotnet' >> $HOME/.zshrc


echo "##################"
echo "# Install vscode #"
echo "##################"
yay -S --noconfirm visual-studio-code-bin