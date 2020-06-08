#!/bin/bash

exec 2>&1
set -e
START_TIME_IMAGE_UPDATE="$(date -u +%s)"

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null

SEKAI_INTEGRITY="_${SEKAI_REPO}_${SEKAI_BRANCH}"

echo "------------------------------------------------"
echo "|    STARTED: VALIDATOR IMAGE UPDATE v0.0.1    |"
echo "------------------------------------------------"

cd $KIRA_WORKSTATION

VALIDATOR_IMAGE_EXISTS=$(./image-updated.sh "$KIRA_DOCKER/validator" "validator" "latest" "$SEKAI_INTEGRITY" || echo "error")
if [ "$VALIDATOR_IMAGE_EXISTS" == "False" ] ; then
    echo "All imags were updated, starting validator image..."
    $KIRA_SCRIPTS/container-delete.sh "validator-1"
    $KIRA_SCRIPTS/container-delete.sh "validator-2"
    $KIRA_SCRIPTS/container-delete.sh "validator-3"
    $KIRA_SCRIPTS/container-delete.sh "validator-4"
    ./update-image.sh "$KIRA_DOCKER/validator" "validator" "latest" "$SEKAI_INTEGRITY" "REPO=$SEKAI_REPO" "BRANCH=$SEKAI_BRANCH"
elif [ "$VALIDATOR_IMAGE_EXISTS" == "True" ] ; then
    echo "INFO: validator-image is up to date"
else
    echo "ERROR: Failed to test if validator image exists"
    exit 1
fi

echo "------------------------------------------------"
echo "| FINISHED: VALIDATOR IMAGE UPDATE v0.0.1      |"
echo "|  ELAPSED: $(($(date -u +%s)-$START_TIME_IMAGE_UPDATE)) seconds"
echo "------------------------------------------------"
