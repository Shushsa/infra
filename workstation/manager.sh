#!/bin/bash

exec 2>&1
set -e

# Local Update Shortcut:
# (rm -fv $KIRA_WORKSTATION/manager.sh) && nano $KIRA_WORKSTATION/manager.sh && chmod 777 $KIRA_WORKSTATION/manager.sh

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null

clear

echo "------------------------------------------------"
echo "|         KIRA NETWORK MANAGER v0.0.1          |"
echo "|             $(date '+%d/%m/%Y %H:%M:%S')"
echo "|----------------------------------------------|"
echo "| [0] | Inspect registry container             |"
echo "| [1] | Inspect validator-1 container          |"
echo "|----------------------------------------------|"
echo "| [R] | Update & Hard Reset Infrastructure     |"
echo "| [S] | View SEKAI repo                        |"
echo "| [I] | View INFRA repo                        |"
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
    echo "Starting code editor..."
    code --user-data-dir /usr/code $KIRA_INFRA
    sleep 3
elif [ "${OPTION,,}" == "s" ] ; then
    echo "Starting code editor..."
    code --user-data-dir /usr/code $KIRA_SEKAI
    sleep 3
elif [ "${OPTION,,}" == "r" ] ; then
    echo "Update and restart infra..."
    gnome-terminal -- bash -c '/kira/start.sh ; $SHELL'
    sleep 3
elif [ "${OPTION,,}" == "x" ] ; then
    exit 0
fi

$KIRA_MANAGER/manager.sh

#GIT_SSH_COMMAND='ssh -i ~/.ssh/your_private_key' git submodule update --init