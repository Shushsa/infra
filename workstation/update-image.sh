#!/bin/bash

exec 2>&1
set -e
set -x

# Local Update Shortcut:
# (rm -fv $KIRA_WORKSTATION/update-image.sh) && nano $KIRA_WORKSTATION/update-image.sh && chmod 777 $KIRA_WORKSTATION/update-image.sh
# Use Example:
# $KIRA_WORKSTATION/update-image.sh "$KIRA_INFRA/docker/base-image" "base-image" "latest"

source "/etc/profile" &> /dev/null

IMAGE_DIR=$1
IMAGE_NAME=$2
IMAGE_TAG=$3
INTEGRITY=$4
BUILD_ARG1=$5
BUILD_ARG2=$6
BUILD_ARG3=$7

[ -z "$IMAGE_TAG" ] && IMAGE_TAG="latest"
[ -z "$BUILD_ARG1" ] && BUILD_ARG1="BUILD_ARG1=none"
[ -z "$BUILD_ARG2" ] && BUILD_ARG2="BUILD_ARG2=none"
[ -z "$BUILD_ARG3" ] && BUILD_ARG3="BUILD_ARG3=none"

KIRA_SETUP_FILE="$KIRA_SETUP/$IMAGE_NAME-$IMAGE_TAG"

# make sure setup file exists
touch $KIRA_SETUP_FILE

cd $IMAGE_DIR

# adding integrity to the hash enables user to update based on internal image state
OLD_HASH=$(cat $KIRA_SETUP_FILE)
NEW_HASH="$(hashdeep -r -l . | sort | md5sum | awk '{print $1}')-$INTEGRITY"

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

if [[ $($KIRA_WORKSTATION/image-updated.sh "$IMAGE_DIR" "$IMAGE_NAME" "$IMAGE_TAG" "$INTEGRITY") != "True" ]] ; then
    
    if [ "$OLD_HASH" != "$NEW_HASH" ] ; then
        echo "WARNING: Image '$IMAGE_DIR' hash changed from $OLD_HASH to $NEW_HASH"
    else
        echo "INFO: Image hash $OLD_HASH did NOT changed, but imgage was not present"
    fi

    # NOTE: This script automaitcaly removes KIRA_SETUP_FILE file (rm -fv $KIRA_SETUP_FILE)
    $KIRA_WORKSTATION/delete-image.sh "$IMAGE_DIR" "$IMAGE_NAME" "$IMAGE_TAG"

    echo "Creating new '$IMAGE_NAME' image..."
    docker build --tag $IMAGE_NAME ./ --build-arg BUILD_HASH=$NEW_HASH --build-arg $BUILD_ARG1 --build-arg $BUILD_ARG2 --build-arg $BUILD_ARG3

    docker image ls # list docker images

    docker tag $IMAGE_NAME:$IMAGE_TAG $KIRA_REGISTRY/$IMAGE_NAME
    docker push $KIRA_REGISTRY/$IMAGE_NAME
    echo $NEW_HASH > $KIRA_SETUP_FILE
else
    echo "INFO: Image '$IMAGE_DIR' ($NEW_HASH) did NOT change" 
fi

curl localhost:5000/v2/_catalog
curl "$KIRA_REGISTRY/v2/$IMAGE_NAME/tags/list"

echo "------------------------------------------------"
echo "|        FINISHED: IMAGE UPDATE v0.0.1         |"
echo "------------------------------------------------"
