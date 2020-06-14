#!/bin/bash

exec 2>&1
set -e

NAME=$1

ETC_PROFILE="/etc/profile"
LOOP_FILE="/tmp/container_manager_loop"
RESTART_SIGNAL="/tmp/rs_container_manager"
source $ETC_PROFILE &> /dev/null
CONTAINER_DUPM="/home/$KIRA_USER/Desktop/DUMP/${NAME^^}"
if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi

while : ; do
    START_TIME="$(date -u +%s)"
    [ -f $RESTART_SIGNAL ] && break

    EXISTS=$($KIRA_SCRIPTS/container-exists.sh "$NAME" || echo "Error")

    if [ "$EXISTS" != "True" ] ; then
        clear
        echo "WARNING: Container $NAME no longer exists, press [X] to exit or restart your infra"
        read -n 1 -t 3 KEY || continue
         [ "${OPTION,,}" == "x" ] && exit 1
    fi

    # (docker ps --no-trunc -aqf name=$NAME) 
    ID=$(docker inspect --format="{{.Id}}" ${NAME} 2> /dev/null || echo "undefined")
    STATUS=$(docker inspect $ID | jq -r '.[0].State.Status' || echo "Error")
    PAUSED=$(docker inspect $ID | jq -r '.[0].State.Paused' || echo "Error")
    HEALTH=$(docker inspect $ID | jq -r '.[0].State.Health.Status' || echo "Error")
    RESTARTING=$(docker inspect $ID | jq -r '.[0].State.Restarting' || echo "Error")
    STARTED_AT=$(docker inspect $ID | jq -r '.[0].State.StartedAt' || echo "Error")
    IP=$(docker inspect $ID | jq -r '.[0].NetworkSettings.Networks.kiranet.IPAMConfig.IPv4Address' || echo "")
    if [ -z "$IP" ] || [ "$IP" == "null" ] ; then IP=$(docker inspect $ID | jq -r '.[0].NetworkSettings.Networks.regnet.IPAMConfig.IPv4Address' || echo "") ; fi
    
    clear
    
    echo -e "\e[36;1m------------------------------------------------"
    echo "|        KIRA CONTAINER MANAGER v0.0.2         |"
    echo "|             $(date '+%d/%m/%Y %H:%M:%S')              |"
    echo "|----------------------------------------------|"
    echo "| Container Name: $NAME ($(echo $ID | head -c 8))"
    echo "|     Ip Address: $IP"
    echo "|----------------------------------------------|"
    echo "|     Status: $STATUS"
    echo "|     Paused: $PAUSED"
    echo "|     Health: $HEALTH"
    echo "| Restarting: $RESTARTING"
    echo "| Started At: $(echo $STARTED_AT | head -c 19)"
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
    
    echo "Input option then press [ENTER] or [SPACE]: " && rm -f $LOOP_FILE && touch $LOOP_FILE
    while : ; do
        OPTION=$(cat $LOOP_FILE)
        [ -z "$OPTION" ] && [ $(($(date -u +%s)-$START_TIME)) -ge 8 ] && break
        read -n 1 -t 3 KEY || continue
        [ ! -z "$KEY" ] && echo "${OPTION}${KEY}" > $LOOP_FILE
        [ -z "$KEY" ] && break
    done
    OPTION=$(cat $LOOP_FILE || echo "") && [ -z "$OPTION" ] && continue
    ACCEPT="" && while [ "${ACCEPT,,}" != "y" ] && [ "${ACCEPT,,}" != "n" ] ; do echo -e "\e[36;1mPress [Y]es to confirm option (${OPTION^^}) or [N]o to cancel: \e[0m\c" && read  -d'' -s -n1 ACCEPT ; done
    echo "" && [ "${ACCEPT,,}" == "n" ] && echo "WARINIG: Operation was cancelled" && continue

    if [ "${OPTION,,}" == "i" ] ; then
        gnome-terminal -- bash -c "docker exec -it $ID /bin/bash || docker exec -it $ID /bin/sh ; read -d'' -s -n1 -p 'Press any key to exit...' && exit"
        break
    elif [ "${OPTION,,}" == "l" ] ; then
        rm -rfv $CONTAINER_DUPM
        mkdir -p $CONTAINER_DUPM
        docker cp $NAME:/var/log/journal $CONTAINER_DUPM/journal || echo "WARNING: Failed to dump journal logs"
        docker cp $NAME:/self/logs $CONTAINER_DUPM/logs || echo "WARNING: Failed to dump self logs"
        docker cp $NAME:/root/.sekaid $CONTAINER_DUPM/sekaid || echo "WARNING: Failed to dump .sekaid config"
        docker cp $NAME:/root/.sekaicli $CONTAINER_DUPM/sekaicli || echo "WARNING: Failed to dump .sekaicli config"
        docker cp $NAME:/etc/systemd/system $CONTAINER_DUPM/systemd || echo "WARNING: Failed to dump systemd services"
        docker cp $NAME:/common $CONTAINER_DUPM/common || echo "WARNING: Failed to dump common directory"
        docker inspect $(docker ps --no-trunc -aqf name=$NAME) > $CONTAINER_DUPM/container-inspect.json || echo "WARNING: Failed to inspect container"
        docker inspect $(docker ps --no-trunc -aqf name=$NAME) > $CONTAINER_DUPM/printenv.txt || echo "WARNING: Failed to fetch printenv"
        docker exec -it $NAME printenv > $CONTAINER_DUPM/printenv.txt || echo "WARNING: Failed to fetch printenv"
        docker logs --timestamps --details $(docker inspect --format="{{.Id}}" ${NAME} 2> /dev/null) > $CONTAINER_DUPM/docker-logs.txt || echo "WARNING: Failed to save docker logs"
        docker container logs --details --timestamps $(docker inspect --format="{{.Id}}" ${NAME} 2> /dev/null) > $CONTAINER_DUPM/container-logs.txt || echo "WARNING: Failed to save container logs"
        systemctl status docker > $CONTAINER_DUPM/docker-status.txt || echo "WARNING: Failed to save docker status info"
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
        echo "INFO: Please wait, refreshing user interface..." && break
    elif [ "${OPTION,,}" == "x" ] ; then
        exit 0
    fi
done

if [ -f $RESTART_SIGNAL ] ; then
    rm -f $RESTART_SIGNAL
else
    touch /tmp/rs_manager
    touch /tmp/rs_git_manager
fi

sleep 1
source $KIRA_MANAGER/container-manager.sh $NAME
