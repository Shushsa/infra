#!/bin/bash

exec 2>&1
set -e

NAME=$1
START_TIME="$(date -u +%s)"
ETC_PROFILE="/etc/profile"

while : ; do
    source $ETC_PROFILE &> /dev/null
    if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi

    CONTAINER_DUPM="/home/$KIRA_USER/Desktop/DUMP/${NAME^^}"
    EXISTS=$($KIRA_SCRIPTS/container-exists.sh "$NAME" || echo "Error")
    STATUS=$(docker inspect $(docker ps --no-trunc -aqf name=$NAME) | jq -r '.[0].State.Status' || echo "Error")
    PAUSED=$(docker inspect $(docker ps --no-trunc -aqf name=$NAME) | jq -r '.[0].State.Paused' || echo "Error")
    HEALTH=$(docker inspect $(docker ps --no-trunc -aqf name=$NAME) | jq -r '.[0].State.Health.Status' || echo "Error")
    RESTARTING=$(docker inspect $(docker ps --no-trunc -aqf name=$NAME) | jq -r '.[0].State.Restarting' || echo "Error")
    STARTED_AT=$(docker inspect $(docker ps --no-trunc -aqf name=$NAME) | jq -r '.[0].State.StartedAt' || echo "Error")
    ID=$(docker inspect --format="{{.Id}}" ${NAME} 2> /dev/null || echo "undefined")
    
    clear
    
    echo -e "\e[36;1m------------------------------------------------"
    echo "|        KIRA CONTAINER MANAGER v0.0.2         |"
    echo "|             $(date '+%d/%m/%Y %H:%M:%S')              |"
    echo "|----------------------------------------------|"
    echo "| Container Name: $NAME ($(echo $ID | head -c 8))"
    echo "|----------------------------------------------|"
    echo "| Container Exists: $EXISTS"
    echo "| Container Status: $STATUS"
    echo "| Container Paused: $PAUSED"
    echo "| Container Health: $HEALTH"
    echo "| Container Restarting: $RESTARTING"
    echo "| Container Started At: $(echo $STARTED_AT | head -c 19)"
    echo "|----------------------------------------------|"
    [ "$EXISTS" == "True" ] && 
    echo "| [I] | Try INSPECT container                  |"
    [ "$EXISTS" == "True" ] && 
    echo "| [L] | View container LOGS                    |"
    [ "$EXISTS" == "True" ] && 
    echo "| [R] | RESTART container                      |"
    [ "$STATUS" == "exited" ] && 
    echo "| [A] | START container                        |"
    [ "$STATUS" == "running" ] && 
    echo "| [S] | STOP container                         |"
    [ "$STATUS" == "running" ] && 
    echo "| [R] | RESTART container                      |"
    [ "$STATUS" == "running" ] && 
    echo "| [P] | PAUSE container                        |"
    [ "$STATUS" == "paused" ] && 
    echo "| [U] | UNPAUSE container                      |"
    [ "$EXISTS" == "True" ] && 
    echo "|----------------------------------------------|"
    echo "| [X] | Exit | [W] | Refresh Window            |"
    echo -e "------------------------------------------------\e[0m"
    
    read  -d'' -s -n1 -t 5 -p "INFO: Press [KEY] to select option" OPTION || OPTION=""
    [ ! -z "$OPTION" ] && echo "" && read -d'' -s -n1 -p "Press [ENTER] to confirm [${OPTION^^}] option or any other key to try again" ACCEPT
    [ ! -z "$ACCEPT" ] && break
    
    if [ "${OPTION,,}" == "i" ] ; then
        gnome-terminal -- docker exec -it $(docker ps -aqf "name=^${NAME}$") bash
        break
    elif [ "${OPTION,,}" == "l" ] ; then
        rm -rfv $CONTAINER_DUPM
        mkdir -p $CONTAINER_DUPM
        docker cp $NAME:/var/log/journal $CONTAINER_DUPM/journal || echo "WARNING: Failed to dump journal logs"
        docker cp $NAME:/self/logs $CONTAINER_DUPM/logs || echo "WARNING: Failed to dump self logs"
        docker cp $NAME:/root/.sekaid $CONTAINER_DUPM/sekaid || echo "WARNING: Failed to dump .sekaid config"
        docker cp $NAME:/root/.sekaicli $CONTAINER_DUPM/sekaicli || echo "WARNING: Failed to dump .sekaicli config"
        docker cp $NAME:/etc/systemd/system $CONTAINER_DUPM/systemd || echo "WARNING: Failed to dump systemd services"
        docker inspect $(docker ps --no-trunc -aqf name=$NAME) > $CONTAINER_DUPM/container-inspect.json || echo "WARNING: Failed to inspect container"
        docker inspect $(docker ps --no-trunc -aqf name=$NAME) > $CONTAINER_DUPM/printenv.txt || echo "WARNING: Failed to fetch printenv"
        docker exec -it $NAME printenv > $CONTAINER_DUPM/printenv.txt || echo "WARNING: Failed to fetch printenv"
        chmod -R 777 $CONTAINER_DUPM
        echo "INFO: Starting code editor..."
        USER_DATA_DIR="/usr/code$CONTAINER_DUPM"
        rm -rf $USER_DATA_DIR
        mkdir -p $USER_DATA_DIR
        code --user-data-dir $USER_DATA_DIR $CONTAINER_DUPM
        break
    elif [ "${OPTION,,}" == "r" ] ; then
        echo "INFO: Restarting container..."
        $KIRA_SCRIPTS/container-restart.sh $NAME
        break
    elif [ "${OPTION,,}" == "a" ] ; then
        echo "INFO: Staring container..."
        $KIRA_SCRIPTS/container-start.sh $NAME
        break
    elif [ "${OPTION,,}" == "s" ] ; then
        echo "INFO: Stopping container..."
        $KIRA_SCRIPTS/container-stop.sh $NAME
        break
    elif [ "${OPTION,,}" == "p" ] ; then
        echo "INFO: Pausing container..."
        $KIRA_SCRIPTS/container-pause.sh $NAME
        break
    elif [ "${OPTION,,}" == "u" ] ; then
        echo "INFO: UnPausing container..."
        $KIRA_SCRIPTS/container-unpause.sh $NAME
        break
    elif [ "${OPTION,,}" == "w" ] ; then
        break
    elif [ "${OPTION,,}" == "x" ] ; then
        exit
    fi
done

sleep 1
source $KIRA_MANAGER/container-manager.sh $NAME
