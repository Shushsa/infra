#!/bin/bash

exec 2>&1
set -e
set -x

# Local Update Shortcut:
# (rm -fv $KIRA_WORKSTATION/start.sh) && nano $KIRA_WORKSTATION/start.sh && chmod 777 $KIRA_WORKSTATION/start.sh

VALIDATOR_CHECKOUT=""
VALIDATOR_BRANCH="master"
VALIDATOR_INTEGRITY="_${VALIDATOR_BRANCH}_${VALIDATOR_CHECKOUT}"

source "/etc/profile" &> /dev/null

echo "Updating repository and fetching changes..."
$KIRA_WORKSTATION/setup.sh
cd $KIRA_WORKSTATION

if [[ $(./image-updated.sh "$KIRA_INFRA/docker/base-image" "base-image") == "False" ]]; then
    $KIRA_SCRIPTS/container-delete.sh "validator-1"
    ./delete-image.sh "$KIRA_INFRA/docker/tools-image" "tools-image"
    ./delete-image.sh "$KIRA_INFRA/docker/validator" "validator"

    echo "Updating base image..."
    ./update-image.sh "$KIRA_INFRA/docker/base-image" "base-image"
else
    echo "INFO: base-image is up to date"
fi

if [[ $(./image-updated.sh "$KIRA_INFRA/docker/tools-image" "tools-image") == "False" ]]; then
    $KIRA_SCRIPTS/container-delete.sh "validator-1"
    ./delete-image.sh "$KIRA_INFRA/docker/validator" "validator"

    echo "Updating tools image..."
    ./update-image.sh "$KIRA_INFRA/docker/tools-image" "tools-image"
else
    echo "INFO: tools-image is up to date"
fi

if [[ $(./image-updated.sh "$KIRA_INFRA/docker/validator" "validator" "latest" "$VALIDATOR_INTEGRITY") == "False" ]]; then
    echo "All imags were updated, starting validator image..."
    $KIRA_SCRIPTS/container-delete.sh "validator-1"
    ./update-image.sh "$KIRA_INFRA/docker/validator" "validator" "latest" "$VALIDATOR_INTEGRITY" "REPO=https://github.com/kiracore/sekai" "BRANCH=$VALIDATOR_BRANCH" "CHECKOUT=$VALIDATOR_CHECKOUT"
else
    echo "INFO: tools-image is up to date"
fi

if [[ $(${KIRA_SCRIPTS}/container-exists.sh "validator-1") == "False" ]] ; then
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
    
else
    echo "Container 'validator-1' already exists."
    docker exec -it validator-1 sekaid version
fi
