
#!/bin/bash

exec 2>&1
set -e

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null
if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi

DEBUG_MODE=$1

if [ "$DEBUG_MODE" == "True" ] ; then
    set -x 
    SILENT_MODE="False"
else
    set +x
    DEBUG_MODE="False"
    SILENT_MODE="True"
fi

SSH_PATH=/home/root/.ssh
KIRA_INFRA=/kira/infra
KIRA_SEKAI=/kira/sekai
KIRA_SETUP=/kira/setup
KIRA_MANAGER="/kira/manager"
KIRA_SCRIPTS="${KIRA_INFRA}/common/scripts"
KIRA_WORKSTATION="${KIRA_INFRA}/workstation"

mkdir -p $SSH_PATH
mkdir -p $KIRA_INFRA
mkdir -p $KIRA_SEKAI
mkdir -p $KIRA_SETUP
mkdir -p $KIRA_MANAGER

KIRA_SETUP_ESSSENTIALS="$KIRA_SETUP/essentials-v0.0.1" 
if [ ! -f "$KIRA_SETUP_ESSSENTIALS" ] ; then
    echo "INFO: Installing Essential Packages and Variables..."
    apt-get update -y > /dev/null
    apt-get install -y --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages \
        software-properties-common apt-transport-https ca-certificates gnupg curl wget git > /dev/null
    
    ln -s /usr/bin/git /bin/git || echo "WARNING: Git symlink already exists"

    echo "INFO: Base Tools Setup..."
    ${KIRA_SCRIPTS}/cdhelper-update.sh "v0.6.12"
    CDHelper version

    echo "INFO: Setting up Essential Variables and Configs..."
    SSHD_CONFIG="/etc/ssh/sshd_config"
    CDHelper text lineswap --insert="PermitRootLogin yes " --prefix="PermitRootLogin" --path=$SSHD_CONFIG --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="PasswordAuthentication yes " --prefix="PasswordAuthentication" --path=$SSHD_CONFIG --append-if-found-not=True --silent=$SILENT_MODE
    service ssh restart || echo "WARNING: Failed to restart ssh service"

    git config --global user.email dev@local
    git config --global core.autocrlf input

    CDHelper text lineswap --insert="KIRA_MANAGER=$KIRA_MANAGER" --prefix="KIRA_MANAGER=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="KIRA_SETUP=$KIRA_SETUP" --prefix="KIRA_SETUP=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="KIRA_INFRA=$KIRA_INFRA" --prefix="KIRA_INFRA=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="KIRA_SEKAI=$KIRA_SEKAI" --prefix="KIRA_SEKAI=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="KIRA_SCRIPTS=$KIRA_SCRIPTS" --prefix="KIRA_SCRIPTS=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="KIRA_WORKSTATION=$KIRA_WORKSTATION" --prefix="KIRA_WORKSTATION=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$

    SSH_KEY_PUB_PATH=$SSH_PATH/id_rsa.pub
    SSH_KEY_PRIV_PATH=$SSH_PATH/id_rsa
    CDHelper text lineswap --insert="SSH_PATH=$SSH_PATH" --prefix="SSH_PATH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="SSH_KEY_PUB_PATH=$SSH_KEY_PUB_PATH" --prefix="SSH_KEY_PUB_PATH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="SSH_KEY_PRIV_PATH=$SSH_KEY_PRIV_PATH" --prefix="SSH_KEY_PRIV_PATH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE

    touch $KIRA_SETUP_ESSSENTIALS
else
    echo "INFO: Essentials were already installed: $(git --version), Curl, Wget..."
fi

CDHelper text lineswap --insert="SILENT_MODE=$SILENT_MODE" --prefix="SILENT_MODE=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="DEBUG_MODE=$DEBUG_MODE" --prefix="DEBUG_MODE=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
