#!/bin/bash

exec 2>&1
set -e
set -x

# Local Update Shortcut:
# (rm -fv $KIRA_WORKSTATION/update-image.sh) && nano $KIRA_WORKSTATION/update-image.sh && chmod 777 $KIRA_WORKSTATION/update-image.sh
# Use Example:
# $KIRA_WORKSTATION/update-image.sh "$KIRA_INFRA/docker/base-image" "base-image" "latest"

source "/etc/profile" > /dev/null

IMAGE_DIR=$1
IMAGE_NAME=$2
IMAGE_TAG=$3
BUILD_ARG1=$4
BUILD_ARG2=$5
BUILD_ARG3=$6

[ -z "$IMAGE_TAG" ] && IMAGE_TAG="latest"
[ -z "$BUILD_ARG1" ] && BUILD_ARG1="BUILD_ARG1=none"
[ -z "$BUILD_ARG2" ] && BUILD_ARG2="BUILD_ARG2=none"
[ -z "$BUILD_ARG3" ] && BUILD_ARG3="BUILD_ARG3=none"

KIRA_SETUP_FILE="$KIRA_SETUP/$IMAGE_NAME-$IMAGE_TAG"

# make sure setup file exists
touch $KIRA_SETUP_FILE

cd $IMAGE_DIR

OLD_HASH=$(cat $KIRA_SETUP_FILE)
NEW_HASH=$(hashdeep -r -l . | sort | md5sum | awk '{print $1}')

echo "------------------------------------------------"
echo "|         STARTED: IMAGE UPDATE v0.0.1         |"
echo "------------------------------------------------"
echo "|     WORKING DIR: $IMAGE_DIR"
echo "|      IMAGE NAME: $IMAGE_NAME"
echo "|       IMAGE TAG: $IMAGE_TAG"
echo "|   OLD REPO HASH: $OLD_HASH"
echo "|   NEW REPO HASH: $NEW_HASH"
echo "|     BUILD ARG 1: $BUILD_ARG1"
echo "|     BUILD ARG 2: $BUILD_ARG2"
echo "|     BUILD ARG 3: $BUILD_ARG3"
echo "------------------------------------------------"

CREATE_NEW_IMAGE="False"
if [ ! -z $(docker images -q $IMAGE_NAME) ] ; then
    echo "SUCCESS: Image '$IMAGE_DIR' was found"
    if [ "$OLD_HASH" == "$NEW_HASH" ] ; then
        echo "INFO: Image '$IMAGE_DIR' hash changed from $OLD_HASH to $NEW_HASH, removing old image..."
        # NOTE: This script automaitcaly removes KIRA_SETUP_FILE file (rm -fv $KIRA_SETUP_FILE)
        $KIRA_WORKSTATION/delete-image.sh "$KIRA_INFRA/docker/tools-image" "tools-image" "latest"
        CREATE_NEW_IMAGE="True"
    else
        echo "INFO: Image hash $OLD_HASH did NOT changed"
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
    docker build --tag $IMAGE_NAME ./ --build-arg BUILD_HASH=$NEW_HASH --build-arg $BUILD_ARG1 --build-arg $BUILD_ARG2 --build-arg $BUILD_ARG3

    docker image ls # list docker images

    docker tag $IMAGE_NAME:$IMAGE_TAG $KIRA_REGISTRY/$IMAGE_NAME
    docker push $KIRA_REGISTRY/$IMAGE_NAME
    echo $NEW_HASH > $KIRA_SETUP_FILE
fi

curl localhost:5000/v2/_catalog
curl "$KIRA_REGISTRY/v2/$IMAGE_NAME/tags/list"

echo "------------------------------------------------"
echo "|        FINISHED: IMAGE UPDATE v0.0.1         |"
echo "------------------------------------------------"
