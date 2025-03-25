#!/bin/sh

# https://github.com/cli/cli/blob/trunk/docs/install_linux.md
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

echo "##################"
echo "# Install dotnet #"
echo "##################"

wget https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh
chmod +x /tmp/dotnet-install.sh
/tmp/dotnet-install.sh --version latest

echo 'export PATH=$HOME/.dotnet:$PATH' >> $HOME/.zshrc
echo 'export DOTNET_ROOT=$HOME/.dotnet' >> $HOME/.zshrc


echo "##################"
echo "# Install awscli #"
echo "##################"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp/awscliv2-install
sudo /tmp/awscliv2-install/aws/install
