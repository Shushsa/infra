#!/bin/bash

exec 2>&1
set -e
set -x

# Local Update Shortcut:
# (rm -fv $KIRA_WORKSTATION/delete-image.sh) && nano $KIRA_WORKSTATION/delete-image.sh && chmod 777 $KIRA_WORKSTATION/delete-image.sh
# Use Example:
# $KIRA_WORKSTATION/delete-image.sh "$KIRA_INFRA/docker/base-image" "base-image" "latest"

source "/etc/profile" &> /dev/null

IMAGE_DIR=$1
IMAGE_NAME=$2
IMAGE_TAG=$3

[ -z "$IMAGE_TAG" ] && IMAGE_TAG="latest"

KIRA_SETUP_FILE="$KIRA_SETUP/$IMAGE_NAME-$IMAGE_TAG"

echo "------------------------------------------------"
echo "|         STARTED: DELETE IMAGE v0.0.1         |"
echo "------------------------------------------------"
echo "|   WORKING DIR: $IMAGE_DIR"
echo "|    IMAGE NAME: $IMAGE_NAME"
echo "|     IMAGE TAG: $IMAGE_TAG"
echo "------------------------------------------------"

cd $IMAGE_DIR

rm -fv $KIRA_SETUP_FILE
docker images -f "dangling=true" -q 
docker images | grep "<none>" | awk '{print $3}' | xargs sudo docker rmi -f || echo "Likely detected child imaged dependencies"
docker rmi -f $(docker images --format '{{.Repository}}:{{.Tag}}' --filter=reference="${IMAGE_NAME}:*") || echo "Image not found"
docker rmi -f $(docker images --format '{{.Repository}}:{{.Tag}}' --filter=reference="${KIRA_REGISTRY}/${IMAGE_NAME}") || echo "Image not found"

echo "------------------------------------------------"
echo "|        FINISHED: IMAGE DELETE v0.0.1         |"
echo "------------------------------------------------"
