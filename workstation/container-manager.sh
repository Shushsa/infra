#!/bin/bash

exec 2>&1
set -e

# Local Update Shortcut:
# (rm -fv $KIRA_WORKSTATION/manager.sh) && nano $KIRA_WORKSTATION/manager.sh && chmod 777 $KIRA_WORKSTATION/manager.sh

NAME=$1

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null

CONTAINER_DUPM="/home/$KIRA_USER/Desktop/${NAME,,,}-DUMP"
mkdir -p $CONTAINER_DUPM

EXISTS=$($KIRA_SCRIPTS/container-exists.sh "$NAME" || echo "Error")
STATUS=$(docker inspect $(docker ps --no-trunc -aqf name=$NAME) | jq -r '.[0].State.Status' || echo "Error")

clear

echo "------------------------------------------------"
echo "|        KIRA CONTAINER MANAGER v0.0.1         |"
echo "|             $(date '+%d/%m/%Y %H:%M:%S')"
echo "|----------------------------------------------|"
echo "| NAME: $NAME"
echo "|----------------------------------------------|"
echo "| Container Exists: $EXISTS"
echo "| Container Status: $STATUS"
echo "|_______________________________________________"
[ "$EXISTS" == "True"] && \
echo "| [1] | Try inspect $NAME container"
[ "$EXISTS" == "True"] && \
echo "| [A] | View $NAME container logs"
echo "|----------------------------------------------|"
echo "| [X] | Exit                                   |"
echo "|_______________________________________________"

read  -d'' -s -n1 -t 5 -p "Press key to select option: " OPTION || OPTION=""
echo ""
[ ! -z $"$OPTION" ] && read -d'' -s -n1 -p "Press [ENTER] to confirm [${OPTION,,,}] option or any other key to try again" ACCEPT
[ ! -z $"$ACCEPT" ] && $KIRA_MANAGER/container-manager.sh $NAME

if [ "$OPTION" == "1" ] ; then
    gnome-terminal -- docker exec -it $(docker ps -aqf "name=^${NAME}$") bash
    sleep 3
elif [ "${OPTION,,}" == "a" ] ; then
    rm -rfv $CONTAINER_DUPM
    docker cp $NAME:/var/log/journal $CONTAINER_DUPM/journal || echo "WARNING: Failed to dump journal logs"
    docker cp $NAME:/self/logs $CONTAINER_DUPM/logs || echo "WARNING: Failed to dump self logs"
    docker cp $NAME:/root/.sekaid $CONTAINER_DUPM/sekaid || echo "WARNING: Failed to dump .sekaid config"
    docker cp $NAME:/root/.sekaicli $CONTAINER_DUPM/sekaicli || echo "WARNING: Failed to dump .sekaicli config"
    docker inspect $(docker ps --no-trunc -aqf name=$NAME) > $CONTAINER_DUPM/container-inspect.json || echo "WARNING: Failed to inspect container"
    chmod -R 777 $CONTAINER_DUPM
    echo "Starting code editor..."
    code --user-data-dir /usr/code $CONTAINER_DUPM
    sleep 3
elif [ "${OPTION,,}" == "u" ] ; then
    echo "Update and restart infra..."
    gnome-terminal -- bash -c '$KIRA_MANAGER/start.sh ; $SHELL'
    sleep 3
elif [ "${OPTION,,}" == "x" ] ; then
    $KIRA_MANAGER/manager.sh
fi

$KIRA_MANAGER/container-manager.sh $NAME



#GIT_SSH_COMMAND='ssh -i ~/.ssh/your_private_key' git submodule update --init