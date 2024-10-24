#/bin/sh
./update.sh

# brew install docker
brew install podman

podman machine init
podman machine start

sudo /opt/homebrew/Cellar/podman/5.2.5/bin/podman-mac-helper install
podman machine stop; podman machine start
        
# sudo touch /usr/local/bin/docker
# sudo bash -c 'echo "#!/bin/bash
# exec podman \"\$@\"" > /usr/local/bin/docker'

# sudo chmod +x /usr/local/bin/docker
