#!/bin/bash

exec 2>&1
set -e

START_TIME="$(date -u +%s)"
ETC_PROFILE="/etc/profile"

while : ; do
    source $ETC_PROFILE &> /dev/null
    if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi
    REGISTRY_STATUS=$(docker inspect $(docker ps --no-trunc -aqf name=registry) | jq -r '.[0].State.Status' || echo "Error")

    clear
    
    echo -e "\e[33;1m------------------------------------------------"
    echo "|         KIRA NETWORK MANAGER v0.0.2          |"
    echo "|             $(date '+%d/%m/%Y %H:%M:%S')              |"
    echo "|----------------------------------------------|"
    echo "| [0] | Inspect registry container             : $REGISTRY_STATUS"
    for ((i=1;i<=$VALIDATORS_COUNT;i++)); do
        VALIDATOR_STATUS=$(docker inspect $(docker ps --no-trunc -aqf name=validator-$i) | jq -r '.[0].State.Status' || echo "Error")
        echo "| [$i] | Inspect validator-$i container          : $VALIDATOR_STATUS"
    done
    echo "|----------------------------------------------|"
    echo "| [I] | Re-INITALIZE Environment               |"
    echo "| [R] | Hard RESET Repos & Infrastructure      |"
    echo "| [D] | DELETE Repos & Infrastructure          |"
    echo "|----------------------------------------------|"
    echo "| [A] | Mange INFRA Repo ($INFRA_BRANCH)"
    echo "| [B] | Mange SEKAI Repo ($SEKAI_BRANCH)"
    echo "|----------------------------------------------|"
    echo "| [X] | Exit | [W] | Refresh Window            |"
    echo -e "------------------------------------------------\e[0m"
    
    read  -d'' -s -n1 -t 5 -p "Press [KEY] to select option: " OPTION || OPTION=""
    [ ! -z "$OPTION" ] && echo "" && read -d'' -s -n1 -p "Press [ENTER] to confirm [${OPTION^^}] option or any other key to try again" ACCEPT
    [ ! -z "$ACCEPT" ] && break

    BREAK="False"
    for ((i=1;i<=$VALIDATORS_COUNT;i++)); do
        if [ "$OPTION" == "$i" ] ; then
            gnome-terminal -- bash -c "$KIRA_MANAGER/container-manager.sh 'validator-1' ; read -d'' -s -n1 -p 'Press any key to exit...' && exit"
            BREAK="True"
            break
        fi 
    done

    [ "$BREAK" == "True" ] && break
    
    if [ "$OPTION" == "0" ] ; then
        gnome-terminal -- bash -c "$KIRA_MANAGER/container-manager.sh 'registry' ; read -d'' -s -n1 -p 'Press any key to exit...' && exit"
        break
    elif [ "${OPTION,,}" == "a" ] ; then
        echo "INFO: Starting git manager..."
        gnome-terminal -- bash -c "$KIRA_MANAGER/git-manager.sh \"$INFRA_REPO_SSH\" \"$INFRA_REPO\" \"$INFRA_BRANCH\" \"$KIRA_INFRA\" \"INFRA_BRANCH\" ; read -d'' -s -n1 -p 'Press any key to exit...' && exit"
        break
    elif [ "${OPTION,,}" == "b" ] ; then
        echo "INFO: Starting git manager..."
        gnome-terminal -- bash -c "$KIRA_MANAGER/git-manager.sh \"$SEKAI_REPO_SSH\" \"$SEKAI_REPO\" \"$SEKAI_BRANCH\" \"$KIRA_SEKAI\" \"SEKAI_BRANCH\" ; read -d'' -s -n1 -p 'Press any key to exit...' && exit"
        break
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
    elif [ "${OPTION,,}" == "w" ] ; then
        break
    elif [ "${OPTION,,}" == "x" ] ; then
        exit 0
    fi
done

sleep 1
source $KIRA_MANAGER/manager.sh

