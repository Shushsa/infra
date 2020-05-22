#!/bin/bash

exec 2>&1
set -e
set -x

# Local Update Shortcut:
# (rm -fv $KIRA_WORKSTATION/start.sh) && nano $KIRA_WORKSTATION/start.sh && chmod 777 $KIRA_WORKSTATION/start.sh

BRANCH=$1
CHECKOUT=$2
SKIP_UPDATE=$3

[ -z "$BRANCH" ] && BRANCH="master"
[ -z "$CHECKOUT" ] && CHECKOUT=""
[ -z "$SKIP_UPDATE" ] && SKIP_UPDATE="False"

VALIDATOR_CHECKOUT=""
VALIDATOR_BRANCH="master"
VALIDATOR_INTEGRITY="_${VALIDATOR_BRANCH}_${VALIDATOR_CHECKOUT}"

source "/etc/profile" &> /dev/null

echo "Updating repository and fetching changes..."
$KIRA_WORKSTATION/setup.sh "$BRANCH" "$CHECKOUT" $SKIP_UPDATE

source "/etc/profile" &> /dev/null

cd $KIRA_WORKSTATION

BASE_IMAGE_EXISTS=$(./image-updated.sh "$KIRA_DOCKER/base-image" "base-image" || echo "error")
if [ "$BASE_IMAGE_EXISTS" == "False" ]; then
    $KIRA_SCRIPTS/container-delete.sh "validator-1"
    ./delete-image.sh "$KIRA_DOCKER/tools-image" "tools-image"
    ./delete-image.sh "$KIRA_DOCKER/validator" "validator"

    echo "Updating base image..."
    ./update-image.sh "$KIRA_DOCKER/base-image" "base-image"
elif [ "$BASE_IMAGE_EXISTS" == "True" ]; then
    echo "INFO: base-image is up to date"
else
    echo "ERROR: Failed to test if base image exists"
    exit 1
fi

TOOLS_IMAGE_EXISTS=$(./image-updated.sh "$KIRA_DOCKER/tools-image" "tools-image" || echo "error")
if [ "$TOOLS_IMAGE_EXISTS" == "False" ]; then
    $KIRA_SCRIPTS/container-delete.sh "validator-1"
    ./delete-image.sh "$KIRA_DOCKER/validator" "validator"

    echo "Updating tools image..."
    ./update-image.sh "$KIRA_DOCKER/tools-image" "tools-image"
elif [ "$TOOLS_IMAGE_EXISTS" == "True" ]; then
    echo "INFO: tools-image is up to date"
else
    echo "ERROR: Failed to test if tools image exists"
    exit 1
fi

VALIDATOR_IMAGE_EXISTS=$(./image-updated.sh "$KIRA_DOCKER/validator" "validator" || echo "error")
if [ "$VALIDATOR_IMAGE_EXISTS" == "False" ]; then
    echo "All imags were updated, starting validator image..."
    $KIRA_SCRIPTS/container-delete.sh "validator-1"
    ./update-image.sh "$KIRA_DOCKER/validator" "validator" "latest" "$VALIDATOR_INTEGRITY" "REPO=https://github.com/kiracore/sekai" "BRANCH=$VALIDATOR_BRANCH" "CHECKOUT=$VALIDATOR_CHECKOUT"
elif [ "$VALIDATOR_IMAGE_EXISTS" == "True" ]; then
    echo "INFO: validator-image is up to date"
else
    echo "ERROR: Failed to test if validator image exists"
    exit 1
fi

CONTAINER_EXISTS=$($KIRA_SCRIPTS/container-exists.sh "validator-1" || echo "error")
if [ "$CONTAINER_EXISTS"== "False" ] ; then
    echo "Container 'validator-1' does NOT exist, creating..."
    ${KIRA_SCRIPTS}/container-delete.sh "validator-1"
    rm -fr "${KIRA_STATE}/validator-1"
    mkdir -p "${KIRA_STATE}/validator-1"
    docker run -d \
 --network="host" \
 --restart=always \
 --name validator-1 \
 -e MONIKER="Kira Hub Validator 1" \
 -e P2P_PROXY_PORT=10000 \
 -e P2P_PROXY_PORT=10001 \
 -e P2P_PROXY_PORT=10002 \
 -e P2P_PROXY_PORT=10003 \
 -e NODE_KEY="node-key-1" \
 -e SIGNING_KEY="signing-1" \
 -e VALIDATOR_KEY="validator-1" \
 -e TEST_KEY="test-1" \
 validator:latest

# docker exec -it $(docker ps -a -q --filter ancestor=validator) bash
# docker run -it --entrypoint /bin/bash validator-1 -s
#> Kira Validator container (HEAD): `docker logs --follow $(docker ps -a -q  --filter ancestor=validator)`
#> Kira Validator container (TAIL): `docker logs --tail 50 --follow --timestamps $(docker ps -a -q  --filter ancestor=validator)`
elif [ "$CONTAINER_EXISTS" == "True" ]; then
    echo "INFO: container validator-1 is running"
    docker exec -it validator-1 sekaid version
else
    echo "ERROR: Failed to test if validator-1 container is running"
    exit 1
fi
