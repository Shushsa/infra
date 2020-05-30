#!/bin/bash

exec 2>&1
set -e
set -x

# Local Update Shortcut:
# (rm -fv $KIRA_WORKSTATION/start.sh) && nano $KIRA_WORKSTATION/start.sh && chmod 777 $KIRA_WORKSTATION/start.sh

SKIP_UPDATE=$1

[ -z "$SKIP_UPDATE" ] && SKIP_UPDATE="False"

ETC_PROFILE="/etc/profile"

source $ETC_PROFILE &> /dev/null

echo "------------------------------------------------"
echo "|       STARTED: KIRA INFRA START v0.0.1       |"
echo "|----------------------------------------------|"
echo "|       INFRA BRANCH: $INFRA_BRANCH"
echo "|       SEKAI BRANCH: $SEKAI_BRANCH"
echo "|         INFRA REPO: $INFRA_REPO"
echo "|         SEKAI REPO: $SEKAI_REPO"
echo "| NOTIFICATION EMAIL: $EMAIL_NOTIFY"
echo "|        SKIP UPDATE: $SKIP_UPDATE"
echo "|_______________________________________________"

[ -z "$INFRA_BRANCH" ] && echo "ERROR: INFRA_BRANCH env was not defined" && exit 1
[ -z "$SEKAI_BRANCH" ] && echo "ERROR: SEKAI_BRANCH env was not defined" && exit 1
[ -z "$INFRA_REPO" ] && echo "ERROR: INFRA_REPO env was not defined" && exit 1
[ -z "$SEKAI_REPO" ] && echo "ERROR: SEKAI_REPO env was not defined" && exit 1
[ -z "$EMAIL_NOTIFY" ] && echo "ERROR: EMAIL_NOTIFY env was not defined" && exit 1

SEKAI_INTEGRITY="_${SEKAI_REPO}_${SEKAI_BRANCH}"

echo "INFO: Updating infra repository and fetching changes..."
$KIRA_WORKSTATION/setup.sh "$SKIP_UPDATE"
source $ETC_PROFILE &> /dev/null

cd $KIRA_WORKSTATION

BASE_IMAGE_EXISTS=$(./image-updated.sh "$KIRA_DOCKER/base-image" "base-image" || echo "error")
if [ "$BASE_IMAGE_EXISTS" == "False" ]; then
    $KIRA_SCRIPTS/container-delete.sh "validator-1"
    ./delete-image.sh "$KIRA_DOCKER/tools-image" "tools-image"
    ./delete-image.sh "$KIRA_DOCKER/validator" "validator"

    echo "INFO: Updating base image..."
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

    echo "INFO: Updating tools image..."
    ./update-image.sh "$KIRA_DOCKER/tools-image" "tools-image"
elif [ "$TOOLS_IMAGE_EXISTS" == "True" ]; then
    echo "INFO: tools-image is up to date"
else
    echo "ERROR: Failed to test if tools image exists"
    exit 1
fi

VALIDATOR_IMAGE_EXISTS=$(./image-updated.sh "$KIRA_DOCKER/validator" "validator" "latest" "$SEKAI_INTEGRITY" || echo "error")
if [ "$VALIDATOR_IMAGE_EXISTS" == "False" ]; then
    echo "All imags were updated, starting validator image..."
    $KIRA_SCRIPTS/container-delete.sh "validator-1"
    ./update-image.sh "$KIRA_DOCKER/validator" "validator" "latest" "$SEKAI_INTEGRITY" "REPO=$SEKAI_REPO" "BRANCH=$SEKAI_BRANCH"
elif [ "$VALIDATOR_IMAGE_EXISTS" == "True" ]; then
    echo "INFO: validator-image is up to date"
else
    echo "ERROR: Failed to test if validator image exists"
    exit 1
fi

$KIRA_SCRIPTS/container-delete.sh "validator-1"
VALIDATOR_1_EXISTS=$($KIRA_SCRIPTS/container-exists.sh "validator-1" || echo "error")

if [ "$VALIDATOR_1_EXISTS" != "False" ] ; then
    echo "ERROR: Failed to delete validator-1 container, status: ${VALIDATOR_1_EXISTS}"
    exit 1
fi

echo "INFO: Creating 'validator-1' container..."
rm -fr "${KIRA_STATE}/validator-1"
mkdir -p "${KIRA_STATE}/validator-1"
docker run -d \
 --network="host" \
 --restart=always \
 --name validator-1 \
 -e MONIKER="Local Kira Hub Validator 1" \
 -e P2P_PROXY_PORT=10000 \
 -e P2P_PROXY_PORT=10001 \
 -e P2P_PROXY_PORT=10002 \
 -e P2P_PROXY_PORT=10003 \
 -e EMAIL_NOTIFY="$EMAIL_NOTIFY" \
 -e SMTP_SECRET="$SMTP_SECRET" \
 -e NODE_KEY="node-key-1" \
 -e SIGNING_KEY="signing-1" \
 -e VALIDATOR_KEY="validator-1" \
 -e TEST_KEY="test-1" \
 validator:latest

echo "INFO: Witing for validator-1 to start..."
sleep 5

echo "INFO: Inspecting if validator-1 is running..."
docker exec -it validator-1 sekaid version || echo "ERROR: sekai not found"

echo "------------------------------------------------"
echo "|      FINISHED: KIRA INFRA START v0.0.1       |"
echo "------------------------------------------------"