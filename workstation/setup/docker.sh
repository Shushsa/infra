
#!/bin/bash

exec 2>&1
set -e

ETC_PROFILE="/etc/profile"

source $ETC_PROFILE &> /dev/null

[ "$DEBUG_MODE" == "True" ] && set -x
[ "$DEBUG_MODE" == "False" ] && set +x

KIRA_SETUP_DOCKER="$KIRA_SETUP/docker-v0.0.1" 
if [ ! -f "$KIRA_SETUP_DOCKER" ] ; then
    echo "INFO: Installing Docker..."
    apt-get update
    apt install docker.io -y
    systemctl2 enable --now docker
    docker -v
    touch $KIRA_SETUP_DOCKER
else
    echo "INFO: Docker $(docker -v) was already installed"
fi
