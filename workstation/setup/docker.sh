
#!/bin/bash

exec 2>&1
set -e

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null
if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi

VERSION=$(docker -v || echo "Error")
KIRA_SETUP_DOCKER="$KIRA_SETUP/docker-v0.0.2" 
if [ ! -f "$KIRA_SETUP_DOCKER" ] || [ "$VERSION" == "Error" ] ; then
    echo "INFO: Installing Docker..."
    apt-get update
    apt install docker.io -y
    systemctl enable --now docker
    docker -v
    touch $KIRA_SETUP_DOCKER
else
    echo "INFO: Docker $(docker -v) was already installed"
fi
