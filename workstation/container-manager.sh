#!/bin/bash

exec 2>&1
set -e

# Local Update Shortcut:
# (rm -fv $KIRA_WORKSTATION/manager.sh) && nano $KIRA_WORKSTATION/manager.sh && chmod 777 $KIRA_WORKSTATION/manager.sh

NAME=$1

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null

CONTAINER_DUPM="/home/$KIRA_USER/Desktop/${NAME^^}-DUMP"
EXISTS=$($KIRA_SCRIPTS/container-exists.sh "$NAME" || echo "Error")
STATUS=$(docker inspect $(docker ps --no-trunc -aqf name=$NAME) | jq -r '.[0].State.Status' || echo "Error")
HEALTH=$(docker inspect $(docker ps --no-trunc -aqf name=$NAME) | jq -r '.[0].State.Health.Status' || echo "Error")
RESTARTING=$(docker inspect $(docker ps --no-trunc -aqf name=$NAME) | jq -r '.[0].State.Restarting' || echo "Error")
STARTED_AT=$(docker inspect $(docker ps --no-trunc -aqf name=$NAME) | jq -r '.[0].State.StartedAt' || echo "Error")
ID=$(docker inspect --format="{{.Id}}" ${name} 2> /dev/null || echo "                              ")

clear

echo "------------------------------------------------"
echo "|        KIRA CONTAINER MANAGER v0.0.1         |"
echo "|             $(date '+%d/%m/%Y %H:%M:%S')"
echo "|----------------------------------------------|"
echo "| Container Name: $NAME"
echo "| Container Id: $(echo $ID | head -c 14)...$(echo $ID | tail -c 13) |"
echo "|----------------------------------------------|"
echo "| Container Exists: $EXISTS"
echo "| Container Status: $STATUS"
echo "| Container Health: $HEALTH"
echo "| Container Restarting: $RESTARTING"
echo "| Container Started At: $STARTED_AT"
echo "|_______________________________________________"
[ "$EXISTS" == "True" ] && 
echo "| [I] | Try INSPECT container"
[ "$EXISTS" == "True" ] && 
echo "| [L] | View container LOGS"
[ "$EXISTS" == "True" ] && 
echo "| [R] | RESTART container"
[ "$EXISTS" == "True" ] && 
echo "| [A] | START container"
[ "$STATUS" == "running" ] && 
echo "| [S] | STOP container"
[ "$EXISTS" == "True" ] && 
echo "| [R] | RESTART container"
[ "$EXISTS" == "True" ] && 
echo "| [P] | PAUSE container"
[ "$EXISTS" == "True" ] && 
echo "| [U] | UNPAUSE container"
[ "$EXISTS" == "True" ] && echo "|----------------------------------------------|"
echo "| [X] | Exit                                   |"
echo "|_______________________________________________"

read  -d'' -s -n1 -t 5 -p "INFO: Press key to select option: " OPTION || OPTION=""
echo ""
[ ! -z $"$OPTION" ] && read -d'' -s -n1 -p "Press [ENTER] to confirm [${OPTION^^}] option or any other key to try again" ACCEPT
[ ! -z $"$ACCEPT" ] && $KIRA_MANAGER/container-manager.sh $NAME

if [ "${OPTION,,}" == "i" ] ; then
    gnome-terminal -- docker exec -it $(docker ps -aqf "name=^${NAME}$") bash
    sleep 3
elif [ "${OPTION,,}" == "l" ] ; then
    rm -rfv $CONTAINER_DUPM
    mkdir -p $CONTAINER_DUPM
    docker cp $NAME:/var/log/journal $CONTAINER_DUPM/journal || echo "WARNING: Failed to dump journal logs"
    docker cp $NAME:/self/logs $CONTAINER_DUPM/logs || echo "WARNING: Failed to dump self logs"
    docker cp $NAME:/root/.sekaid $CONTAINER_DUPM/sekaid || echo "WARNING: Failed to dump .sekaid config"
    docker cp $NAME:/root/.sekaicli $CONTAINER_DUPM/sekaicli || echo "WARNING: Failed to dump .sekaicli config"
    docker inspect $(docker ps --no-trunc -aqf name=$NAME) > $CONTAINER_DUPM/container-inspect.json || echo "WARNING: Failed to inspect container"
    docker inspect $(docker ps --no-trunc -aqf name=$NAME) > $CONTAINER_DUPM/printenv.txt || echo "WARNING: Failed to fetch printenv"
    docker exec -it $NAME printenv > $CONTAINER_DUPM/printenv.txt || echo "WARNING: Failed to fetch printenv"
    chmod -R 777 $CONTAINER_DUPM
    echo "INFO: Starting code editor..."
    code --user-data-dir /usr/code $CONTAINER_DUPM
    sleep 3
elif [ "${OPTION,,}" == "r" ] ; then
    echo "INFO: Restarting container..."
    $KIRA_SCRIPTS/container-restart.sh $NAME
    sleep 3
elif [ "${OPTION,,}" == "a" ] ; then
    echo "INFO: Staring container..."
    $KIRA_SCRIPTS/container-start.sh $NAME
    sleep 3
elif [ "${OPTION,,}" == "s" ] ; then
    echo "INFO: Stopping container..."
    $KIRA_SCRIPTS/container-stop.sh $NAME
    sleep 3
elif [ "${OPTION,,}" == "p" ] ; then
    echo "INFO: Pausing container..."
    $KIRA_SCRIPTS/container-pause.sh $NAME
    sleep 3
elif [ "${OPTION,,}" == "u" ] ; then
    echo "INFO: UnPausing container..."
    $KIRA_SCRIPTS/container-unpause.sh $NAME
    sleep 3
elif [ "${OPTION,,}" == "x" ] ; then
    $KIRA_MANAGER/manager.sh
fi

$KIRA_MANAGER/container-manager.sh $NAME


#GIT_SSH_COMMAND='ssh -i ~/.ssh/your_private_key' git submodule update --init