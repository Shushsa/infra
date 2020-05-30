#!/bin/bash

exec 2>&1
set -e

# Local Update Shortcut:
# (rm -fv $KIRA_WORKSTATION/manager.sh) && nano $KIRA_WORKSTATION/manager.sh && chmod 777 $KIRA_WORKSTATION/manager.sh

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null

REGISTRY_STATUS=$(docker inspect $(docker ps --no-trunc -aqf name=registry) | jq -r '.[0].State.Status' || echo "Error")
VALIDATOR_1_STATUS=$(docker inspect $(docker ps --no-trunc -aqf name=validator-1) | jq -r '.[0].State.Status' || echo "Error")

clear

echo "------------------------------------------------"
echo "|         KIRA NETWORK MANAGER v0.0.1          |"
echo "|             $(date '+%d/%m/%Y %H:%M:%S')"
echo "|----------------------------------------------|"
echo "| [0] | Inspect registry container    | $REGISTRY_STATUS"
echo "| [1] | Inspect validator-1 container | $VALIDATOR_1_STATUS"
echo "|----------------------------------------------|"
echo "| [W] | WIPE & Re-Initialize Environment       |"
echo "| [R] | Hard RESET Repos & Infrastructure      |"
echo "| [D] | DELETE Repos & Environment             |"
echo "| [S] | View SEKAI Repo ($SEKAI_BRANCH)"
echo "| [I] | View INFRA Repo ($INFRA_BRANCH)"
echo "| [X] | EXIT                                   |"
echo "|_______________________________________________"

read  -d'' -s -n1 -t 5 -p "Press key to select option: " OPTION || OPTION=""
echo ""
[ ! -z $"$OPTION" ] && read -d'' -s -n1 -p "Press [ENTER] to confirm [${OPTION,,,}] option or any other key to try again" ACCEPT
[ ! -z $"$ACCEPT" ] && $KIRA_MANAGER/manager.sh

if [ "$OPTION" == "0" ] ; then
    $KIRA_MANAGER/container-manager.sh "registry"
    sleep 3
elif [ "$OPTION" == "1" ] ; then
    $KIRA_MANAGER/container-manager.sh "validator-1"
    sleep 3
elif [ "${OPTION,,}" == "i" ] ; then
    echo "INFO: Starting code editor..."
    code --user-data-dir /usr/code $KIRA_INFRA
    sleep 3
elif [ "${OPTION,,}" == "s" ] ; then
    echo "INFO: Starting code editor..."
    code --user-data-dir /usr/code $KIRA_SEKAI
    sleep 3
elif [ "${OPTION,,}" == "w" ] ; then
    echo "INFO: Wiping and re-initializing..."
    gnome-terminal -- bash -c "$KIRA_MANAGER/init.sh False ; \$SHELL"
    sleep 3
elif [ "${OPTION,,}" == "r" ] ; then
    echo "INFO: Wiping and Restarting infra..."
    gnome-terminal -- bash -c "$KIRA_MANAGER/start.sh ; \$SHELL"
    sleep 3
elif [ "${OPTION,,}" == "d" ] ; then
    echo "INFO: Wiping and removing infra..."
    gnome-terminal -- bash -c "$KIRA_MANAGER/delete.sh ; \$SHELL"
    sleep 3
elif [ "${OPTION,,}" == "x" ] ; then
    exit 0
fi

$KIRA_MANAGER/manager.sh

#GIT_SSH_COMMAND='ssh -i ~/.ssh/your_private_key' git submodule update --init