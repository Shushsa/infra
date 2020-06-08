#!/bin/bash

exec 2>&1
set -e
START_TIME_CONTAINER_AWAIT="$(date -u +%s)"

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null

NAME=$1
TIMEOUT=$2

echo "------------------------------------------------"
echo "| STARTED: AWAITING CONTAINER INIT v0.0.1      |"
echo "|-----------------------------------------------"
echo "|    NAME: $1"
echo "| TIMEOUT: $2 seconds"
echo "------------------------------------------------"

TARGET_PASS_FILE="/self/home/success_end"
TARGET_FAIL_FILE="/self/home/failure_start"
DESTINATION="/tmp/$NAME"
SUCCESS="False"
ELAPSED=0
mkdir -p $DESTINATION

while [ $ELAPSED -le $TIMEOUT ] && [ "$SUCCESS" == "False" ] ; do
    ELAPSED=$(($(date -u +%s)-$START_TIME_CONTAINER_AWAIT))
    CONTAINER_EXISTS=$($KIRA_SCRIPTS/container-exists.sh $NAME || echo "error")
    if [ "$CONTAINER_EXISTS" != "True"  ] ; then
        continue
    fi

    SUCCESS="True"
    ERROR="True"
    docker cp $NAME:$TARGET_PASS_FILE "$DESTINATION/tmp-pass.file" || SUCCESS="False"
    docker cp $NAME:$TARGET_FAIL_FILE "$DESTINATION/tmp-fail.file" || ERROR="False"

    if [ "$ERROR" == "True" ] ; then
        echo "ERROR: Fail report file was found wihtin container $NAME after $ELAPSED seconds"
        exit 1
    fi

    sleep 1
done

if [ "$SUCCESS" == "False" ] ; then
    echo "ERROR: Awaitng for container $NAME to init, timeouted after $ELAPSED seconds"
    exit 1
fi

echo "------------------------------------------------"
echo "| FINISHED: AWAITING CONTAINER INIT v0.0.1     |"
echo "|  ELAPSED: $(($(date -u +%s)-$START_TIME_CONTAINER_AWAIT)) seconds"
echo "------------------------------------------------"
