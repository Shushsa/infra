#!/bin/bash

exec 2>&1
set -e

# Local Update Shortcut:
# (rm -fv $KIRA_WORKSTATION/start.sh) && nano $KIRA_WORKSTATION/start.sh && chmod 777 $KIRA_WORKSTATION/start.sh

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null

VALIDATOR_1_DUPM="/home/$KIRA_USER/Desktop/validator-1-DUMP"
mkdir -p $VALIDATOR_1_DUPM

VALIDATOR_1_EXISTS=$($KIRA_SCRIPTS/container-exists.sh "validator-1" || echo "Error")

clear

echo "------------------------------------------------"
echo "|         KIRA NETWORK MANAGER v0.0.1          |"
echo "|             $(date '+%d/%m/%Y %H:%M:%S')"
echo "|----------------------------------------------|"
echo "| validator-1 running: {$VALIDATOR_1_EXISTS}"
echo "|_______________________________________________"
echo "| [1] | Try inspect validator-1 container      |"
echo "| [A] | View validator-1 container logs        |"
echo "|----------------------------------------------|"
echo "| [U] | Update & restart containers            |"
echo "| [S] | View sekai repo                        |"
echo "| [I] | View infrastructure repo               |"
echo "| [X] | Exit                                   |"
echo "| [ ] | Clear & Refresh                        |"
echo "|_______________________________________________"

read  -d'' -s -n1 -t 5 -p "Press key to select option: " OPTION

[ ! -z $"$OPTION" ] && read -d'' -s -n1 -p "Press [ENTER] to confirm [${OPTION,,,}] option or any other key to try again" ACCEPT
[ ! -z $"$ACCEPT" ] && $KIRA_WORKSTATION/manager.sh

if [ "$OPTION" == "1" ] ; then
    gnome-terminal -- docker exec -it $(docker ps -aqf "name=^validator-1$") bash
    sleep 3
elif [ "${OPTION,,}" == "a" ] ; then
    rm -rfv $VALIDATOR_1_DUPM
    docker cp validator-1:/var/log/journal $VALIDATOR_1_DUPM/journal || echo "Failed to dump journal logs"
    docker cp validator-1:/self/logs $VALIDATOR_1_DUPM/logs || echo "Failed to dump self logs"
    docker cp validator-1:/root/.sekaid $VALIDATOR_1_DUPM/sekaid || echo "Failed to dump .sekaid config"
    docker cp validator-1:/root/.sekaicli $VALIDATOR_1_DUPM/sekaicli || echo "Failed to dump .sekaicli config"
    chmod -R 777 $VALIDATOR_1_DUPM
    echo "Starting code editor..."
    code --user-data-dir /usr/code $VALIDATOR_1_DUPM
    sleep 3
elif [ "${OPTION,,}" == "i" ] ; then
    echo "Starting code editor..."
    code --user-data-dir /usr/code $KIRA_INFRA
    sleep 3
elif [ "${OPTION,,}" == "s" ] ; then
    echo "Starting code editor..."
    code --user-data-dir /usr/code $KIRA_INFRA/sekai
    sleep 3
elif [ "${OPTION,,}" == "u" ] ; then
    echo "Update and restart infra..."
    gnome-terminal -- bash -c '/kira/start.sh ; $SHELL'
    sleep 3
elif [ "${OPTION,,}" == "x" ] ; then
    exit 0
fi

$KIRA_WORKSTATION/manager.sh
