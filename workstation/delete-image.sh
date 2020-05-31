#!/bin/bash

exec 2>&1
set -e

# Local Update Shortcut:
# (rm -fv $KIRA_WORKSTATION/delete-image.sh) && nano $KIRA_WORKSTATION/delete-image.sh && chmod 777 $KIRA_WORKSTATION/delete-image.sh
# Use Example:
# $KIRA_WORKSTATION/delete-image.sh "$KIRA_INFRA/docker/base-image" "base-image" "latest"

source "/etc/profile" &> /dev/null

IMAGE_DIR=$1
IMAGE_NAME=$2
IMAGE_TAG=$3

[ "$DEBUG_MODE" == "True" ] && set -x
[ "$DEBUG_MODE" == "False" ] && set +x
[ -z "$IMAGE_TAG" ] && IMAGE_TAG="latest"

KIRA_SETUP_FILE="$KIRA_SETUP/$IMAGE_NAME-$IMAGE_TAG"
IMAGE=$(docker images --format '{{.Repository}}:{{.Tag}}' --filter=reference="${IMAGE_NAME}:*" || echo "none")
REGISTRY_IMAGE=$(docker images --format '{{.Repository}}:{{.Tag}}' --filter=reference="${KIRA_REGISTRY}/${IMAGE_NAME}" || echo "none")

echo "------------------------------------------------"
echo "|         STARTED: DELETE IMAGE v0.0.1         |"
echo "------------------------------------------------"
echo "|    WORKING DIR: $IMAGE_DIR"
echo "|     IMAGE NAME: $IMAGE_NAME"
echo "|      IMAGE TAG: $IMAGE_TAG"
echo "|          IMAGE: $IMAGE"
echo "| REGISTRY IMAGE: $REGISTRY_IMAGE"
echo "------------------------------------------------"

cd $IMAGE_DIR

rm -fv $KIRA_SETUP_FILE
docker images -f "dangling=true" -q 
docker images | grep "<none>" | awk '{print $3}' | xargs sudo docker rmi -f || echo "Likely detected child imaged dependencies"
[ "$IMAGE" != "none" ] && docker rmi -f $IMAGE || echo "Image not found"
[ "$REGISTRY_IMAGE" != "none" ] &&  rmi -f $REGISTRY_IMAGE || echo "Image not found"

# ensure registry cleanup
docker exec -it registry sh -c "rm -rfv /var/lib/registry/docker/registry/v2/repositories/${IMAGE_NAME}" || echo "Imgae was not present in the registry"
docker exec -it registry bin/registry garbage-collect /etc/docker/registry/config.yml -m  || echo "Failed to collect registry garbage"
docker exec -it registry sh -c "reboot" || echo "Docker Registry Reboot" && sleep 1

echo "------------------------------------------------"
echo "|        FINISHED: IMAGE DELETE v0.0.1         |"
echo "------------------------------------------------"
