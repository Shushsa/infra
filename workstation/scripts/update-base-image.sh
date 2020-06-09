#!/bin/bash

exec 2>&1
set -e
START_TIME_IMAGE_UPDATE="$(date -u +%s)"

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null

echo "------------------------------------------------"
echo "|      STARTED: BASE IMAGE UPDATE v0.0.1        |"
echo "------------------------------------------------"

cd $KIRA_WORKSTATION

BASE_IMAGE_EXISTS=$(./image-updated.sh "$KIRA_DOCKER/base-image" "base-image" || echo "error")
if [ "$BASE_IMAGE_EXISTS" == "False" ] ; then
    ./delete-image.sh "$KIRA_DOCKER/tools-image" "tools-image"
    ./delete-image.sh "$KIRA_DOCKER/validator" "validator"

    echo "INFO: Updating base image..."
    ./update-image.sh "$KIRA_DOCKER/base-image" "base-image"
elif [ "$BASE_IMAGE_EXISTS" == "True" ] ; then
    echo "INFO: base-image is up to date"
else
    echo "ERROR: Failed to test if base image exists"
    exit 1
fi

echo "------------------------------------------------"
echo "| FINISHED: BASE IMAGE UPDATE v0.0.1           |"
echo "|  ELAPSED: $(($(date -u +%s)-$START_TIME_IMAGE_UPDATE)) seconds"
echo "------------------------------------------------"
