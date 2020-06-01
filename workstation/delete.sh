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

cd $KIRA_WORKSTATION

$KIRA_SCRIPTS/container-delete.sh "validator-1"
./delete-image.sh "$KIRA_DOCKER/base-image" "base-image"
./delete-image.sh "$KIRA_DOCKER/tools-image" "tools-image"
./delete-image.sh "$KIRA_DOCKER/validator" "validator"

echo "------------------------------------------------"
echo "|      STARTED: KIRA INFRA DELETE v0.0.1       |"
echo "------------------------------------------------"
