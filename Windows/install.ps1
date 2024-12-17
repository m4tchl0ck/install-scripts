winget install --id=twpayne.chezmoi  -e
winget install github-cli
gh auth setup-git
winget install vscode
winget install --id=direnv.direnv  -e
[Environment]::SetEnvironmentVariable("DIRENV_CONFIG", "$env:APPDATA\direnv\conf", [System.EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("XDG_CACHE_HOME", "$env:APPDATA\direnv\cache", [System.EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("XDG_DATA_HOME", "$env:APPDATA\direnv\data", [System.EnvironmentVariableTarget]::User)

winget install podman
podman machine init
podman machine start
# for compatibility with docker
echo "Set-Alias -Name docker -Value podman -Scope Global" >> $profile

winget install RedHat.Podman-Desktop

# Go to  Settings > Resources.
# In the Compose tile, click Setup, and follow the prompts.

winget install Microsoft.DotNet.SDK.9

winget install -e --id SUSE.RancherDesktop
winget install -e --id Amazon.AWSCLI
winget install -e --id GnuPG.Gpg4win
