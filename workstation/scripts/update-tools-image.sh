#!/bin/bash

exec 2>&1
set -e
START_TIME_IMAGE_UPDATE="$(date -u +%s)"

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null

echo "------------------------------------------------"
echo "|      STARTED: TOOLS IMAGE UPDATE v0.0.1      |"
echo "------------------------------------------------"

cd $KIRA_WORKSTATION

TOOLS_IMAGE_EXISTS=$(./image-updated.sh "$KIRA_DOCKER/tools-image" "tools-image" || echo "error")
if [ "$TOOLS_IMAGE_EXISTS" == "False" ] ; then
    ./delete-image.sh "$KIRA_DOCKER/validator" "validator"

    echo "INFO: Updating tools image..."
    ./update-image.sh "$KIRA_DOCKER/tools-image" "tools-image"
elif [ "$TOOLS_IMAGE_EXISTS" == "True" ] ; then
    echo "INFO: tools-image is up to date"
else
    echo "ERROR: Failed to test if tools image exists"
    exit 1
fi

echo "------------------------------------------------"
echo "| FINISHED: TOOLS IMAGE UPDATE v0.0.1          |"
echo "|  ELAPSED: $(($(date -u +%s)-$START_TIME_IMAGE_UPDATE)) seconds"
echo "------------------------------------------------"
