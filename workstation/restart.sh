#!/bin/bash

exec 2>&1
set -e

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null
if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi

SKIP_UPDATE=$1
[ -z "$SKIP_UPDATE" ] && SKIP_UPDATE="False"

echo "------------------------------------------------"
echo "|       STARTED: KIRA INFRA STOP v0.0.1        |"
echo "------------------------------------------------"

CONTAINERS=$(docker ps -a | awk '{if(NR>1) print $NF}' | tac)
for CONTAINER in $CONTAINERS ; do
    $KIRA_SCRIPTS/container-restart.sh $CONTAINER
done

echo "INFO: Restarting network manager"
systemctl restart NetworkManager docker || echo "ERROR: Failed to restart docker Network Manager"

echo "------------------------------------------------"
echo "|      FINISHED: KIRA INFRA STOP v0.0.1        |"
echo "------------------------------------------------"
