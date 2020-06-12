#!/bin/bash

exec 2>&1
set -e

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null
if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi

SKIP_UPDATE=$1
[ -z "$SKIP_UPDATE" ] && SKIP_UPDATE="False"

echo "------------------------------------------------"
echo "|      STARTED: KIRA INFRA DELETE v0.0.1       |"
echo "------------------------------------------------"

for ((i=1;i<=$MAX_VALIDATORS;i++)); do
    $KIRA_SCRIPTS/container-delete.sh "validator-$i"
done

$KIRA_SCRIPTS/container-delete.sh "registry"
$WORKSTATION_SCRIPTS/delete-image.sh "$KIRA_DOCKER/base-image" "base-image"
$WORKSTATION_SCRIPTS/delete-image.sh "$KIRA_DOCKER/tools-image" "tools-image"
$WORKSTATION_SCRIPTS/delete-image.sh "$KIRA_DOCKER/validator" "validator"

docker stop `docker ps -qa` || echo "WARNING: Faile to docker stop all processess"
docker rmi -f `docker images -qa` || echo "WARNING: Faile to remove all docker images"
docker system prune -a -f || echo "WARNING: Docker prune failed"
docker volume prune -f || echo "WARNING: Failed to prune volumes"

docker network rm kiranet || echo "WARNING: Failed to remove kira network"
docker network rm regnet || echo "WARNING: Failed to remove registry network"
docker network prune -f || echo "WARNING: Failed to prune all networks"
echo "------------------------------------------------"
echo "|      STARTED: KIRA INFRA DELETE v0.0.1       |"
echo "------------------------------------------------"
