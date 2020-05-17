#!/bin/bash

exec 2>&1
set -e
set -x

source /etc/profile

# $KIRA_WORKSTATION/update-image "$KIRA_INFRA/docker/base-image" "base-image" "latest"

IMAGE_DIR=$KIRA_INFRA/docker/base-image
IMAGE_NAME=base-image
IMAGE_TAG=latest

KIRA_SETUP_FILE="$KIRA_SETUP/$IMAGE_NAME-$IMAGE_TAG"

# make sure setup file exists
touch $KIRA_SETUP_FILE

cd $IMAGE_DIR

OLD_HASH=$(cat $KIRA_SETUP_FILE)
NEW_HASH=$(hashdeep -r -l . | sort | md5sum | awk '{print $1}')

CREATE_NEW_IMAGE="False"
if [ -z $(docker images -q $IMAGE_NAME) ] ; then
    echo "SUCCESS: Image '$IMAGE_DIR' was found"
    if [ "$OLD_HASH" == "$NEW_HASH" ] ; then
        echo "INFO: Image '$IMAGE_DIR' hash changed from $OLD_HASH to $NEW_HASH, removing old image..."
        docker images -f "dangling=true" -q 
        docker images | grep "<none>" | awk '{print $3}' | xargs sudo docker rmi -f || echo "Likely detected child imaged dependencies"
        docker rmi -f $(docker images --format '{{.Repository}}:{{.Tag}}' --filter=reference="${IMAGE_NAME}:*") || echo "Image not found"
        docker rmi -f $(docker images --format '{{.Repository}}:{{.Tag}}' --filter=reference="${KIRA_REGISTRY}/${IMAGE_NAME}") || echo "Image not found"

        #docker rmi -f "${KIRA_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}" || echo "faile d"
        #docker rmi -f "${IMAGE_NAME}:${IMAGE_TAG}"
    fi
else
    echo "WARNING: Image '$IMAGE_DIR' was NOT found"
    CREATE_NEW_IMAGE="True"
fi

if [ "$CREATE_NEW_IMAGE" == "True" ] ; then
    # ensure cleanup
    docker exec -it registry sh -c "rm -rfv /var/lib/registry/docker/registry/v2/repositories/${IMAGE_NAME}"
    docker exec -it registry bin/registry garbage-collect /etc/docker/registry/config.yml -m
    docker exec -it registry sh -c "reboot" || echo "Docker Registry Reboot" && sleep 3

    echo "Creating new '$IMAGE_NAME' image..."
    docker build --tag $IMAGE_NAME ./

    docker image ls # list docker images

    docker tag $IMAGE_NAME:$IMAGE_TAG $KIRA_REGISTRY/$IMAGE_NAME
    docker push $KIRA_REGISTRY/$IMAGE_NAME
    echo $NEW_HASH > $KIRA_SETUP_FILE
fi

curl localhost:5000/v2/_catalog
curl "${KIRA_REGISTRY}/v2/${IMAGE_NAME}/tags/list"


