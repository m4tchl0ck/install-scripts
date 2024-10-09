#!/bin/sh

./update.sh

# https://github.com/cli/cli/blob/trunk/docs/install_linux.md
echo '##################'
echo '# Install gh-cli #'
echo '##################'
brew install gh

echo "##################"
echo "# Install dotnet #"
echo "##################"
brew install dotnet
brew install --cask dotnet-sdk

echo "##################"
echo "# Install vscode #"
echo "##################"
brew install --cask visual-studio-code


brew install awscli
