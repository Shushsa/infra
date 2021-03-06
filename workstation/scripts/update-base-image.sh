#!/bin/bash

exec 2>&1
set -e
set -x

START_TIME_IMAGE_UPDATE="$(date -u +%s)"
source "/etc/profile" &> /dev/null

echo "------------------------------------------------"
echo "|      STARTED: BASE IMAGE UPDATE v0.0.1        |"
echo "------------------------------------------------"

BASE_IMAGE_EXISTS=$($WORKSTATION_SCRIPTS/image-updated.sh "$KIRA_DOCKER/base-image" "base-image" || echo "error")
if [ "$BASE_IMAGE_EXISTS" == "False" ] ; then
    $WORKSTATION_SCRIPTS/delete-image.sh "$KIRA_DOCKER/tools-image" "tools-image" #1
    $WORKSTATION_SCRIPTS/delete-image.sh "$KIRA_DOCKER/validator" "validator" #2 (+1)

    echo "INFO: Updating base image..."
    $WORKSTATION_SCRIPTS/update-image.sh "$KIRA_DOCKER/base-image" "base-image" #6 (+4)
elif [ "$BASE_IMAGE_EXISTS" == "True" ] ; then
    $KIRA_SCRIPTS/progress-touch.sh "+6" #6
    echo "INFO: base-image is up to date"
else
    echo "ERROR: Failed to test if base image exists"
    exit 1
fi

echo "------------------------------------------------"
echo "| FINISHED: BASE IMAGE UPDATE v0.0.1           |"
echo "|  ELAPSED: $(($(date -u +%s)-$START_TIME_IMAGE_UPDATE)) seconds"
echo "------------------------------------------------"
