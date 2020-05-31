#!/bin/bash

exec 2>&1
set -e

SKIP_UPDATE=$1

[ -z "$SKIP_UPDATE" ] && SKIP_UPDATE="False"

ETC_PROFILE="/etc/profile"

source $ETC_PROFILE &> /dev/null
[ "$DEBUG_MODE" == "True" ] && set -x
[ "$DEBUG_MODE" == "False" ] && set +x

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
