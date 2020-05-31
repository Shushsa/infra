#!/bin/bash

exec 2>&1
set -e

START_TIME="$(date -u +%s)"
ETC_PROFILE="/etc/profile"

while : ; do
    source $ETC_PROFILE &> /dev/null
    REGISTRY_STATUS=$(docker inspect $(docker ps --no-trunc -aqf name=registry) | jq -r '.[0].State.Status' || echo "Error")
    VALIDATOR_1_STATUS=$(docker inspect $(docker ps --no-trunc -aqf name=validator-1) | jq -r '.[0].State.Status' || echo "Error")
    
    clear
    
    echo -e "\e[33;1m------------------------------------------------"
    echo "|         KIRA NETWORK MANAGER v0.0.2          |"
    echo "|             $(date '+%d/%m/%Y %H:%M:%S')              |"
    echo "|----------------------------------------------|"
    echo "| [0] | Inspect registry container             : $REGISTRY_STATUS"
    echo "| [1] | Inspect validator-1 container          : $VALIDATOR_1_STATUS"
    echo "|----------------------------------------------|"
    echo "| [I] | Re-INITALIZE Environment               |"
    echo "| [R] | Hard RESET Repos & Infrastructure      |"
    echo "| [D] | DELETE Repos & Infrastructure          |"
    echo "|----------------------------------------------|"
    echo "| [A] | View INFRA Repo ($INFRA_BRANCH)"
    echo "| [B] | View SEKAI Repo ($SEKAI_BRANCH)"
    echo "|----------------------------------------------|"
    echo "| [X] | EXIT                                   |"
    echo -e "------------------------------------------------\e[0m"
    
    read  -d'' -s -n1 -t 3 -p "Press [KEY] to select option: " OPTION || OPTION=""
    [ ! -z $"$OPTION" ] && echo ""
    [ ! -z $"$OPTION" ] && read -d'' -s -n1 -p "Press [ENTER] to confirm [${OPTION^^}] option or any other key to try again" ACCEPT
    [ ! -z $"$ACCEPT" ] && break
    
    if [ "$OPTION" == "0" ] ; then
        gnome-terminal -- bash -c "$KIRA_MANAGER/container-manager.sh 'registry' ; read -d'' -s -n1 -p 'Press any key to exit...' && exit"
        sleep 1
    elif [ "$OPTION" == "1" ] ; then
        gnome-terminal -- bash -c "$KIRA_MANAGER/container-manager.sh 'validator-1' ; read -d'' -s -n1 -p 'Press any key to exit...' && exit"
        sleep 1
    elif [ "${OPTION,,}" == "a" ] ; then
        echo "INFO: Starting code editor..."
        code --user-data-dir /usr/code $KIRA_INFRA
        sleep 1
    elif [ "${OPTION,,}" == "b" ] ; then
        echo "INFO: Starting code editor..."
        code --user-data-dir /usr/code $KIRA_SEKAI
        sleep 1
    elif [ "${OPTION,,}" == "i" ] ; then
        echo "INFO: Wiping and re-initializing..."
        echo -e "\e[33;1mWARNING: You have to wait for new process to finish\e[0m"
        gnome-terminal --disable-factory -- bash -c "$KIRA_MANAGER/init.sh False ; read -d'' -s -n1 -p 'Press any key to exit...' && exit"
        break
    elif [ "${OPTION,,}" == "r" ] ; then
        echo "INFO: Wiping and Restarting infra..."
        echo -e "\e[33;1mWARNING: You have to wait for new process to finish\e[0m"
        gnome-terminal --disable-factory -- bash -c "$KIRA_MANAGER/start.sh ; read -d'' -s -n1 -p 'Press any key to exit...' && exit"
        break
    elif [ "${OPTION,,}" == "d" ] ; then
        echo "INFO: Wiping and removing infra..."
        echo -e "\e[33;1mWARNING: You have to wait for new process to finish\e[0m"
        gnome-terminal --disable-factory -- bash -c "$KIRA_MANAGER/delete.sh ; read -d'' -s -n1 -p 'Press any key to exit...' && exit"
        break
    elif [ "${OPTION,,}" == "x" ] ; then
        exit 0
    fi
done

sleep 1
source $KIRA_MANAGER/manager.sh

