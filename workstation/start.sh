#!/bin/bash

exec 2>&1
set -e
START_TIME_INFRA="$(date -u +%s)"

# Local Update Shortcut:
# (rm -fv $KIRA_WORKSTATION/start.sh) && nano $KIRA_WORKSTATION/start.sh && chmod 777 $KIRA_WORKSTATION/start.sh

SKIP_UPDATE=$1

[ -z "$SKIP_UPDATE" ] && SKIP_UPDATE="False"

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null

[ "$DEBUG_MODE" == "True" ] && set -x

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

echo "INFO: Updating infra repository and fetching changes..."
$KIRA_WORKSTATION/setup.sh "$SKIP_UPDATE"
source $ETC_PROFILE &> /dev/null

$KIRA_SCRIPTS/container-restart.sh "registry"
$KIRA_SCRIPTS/container-delete.sh "validator-1"
$KIRA_SCRIPTS/container-delete.sh "validator-2"
$KIRA_SCRIPTS/container-delete.sh "validator-3"
$KIRA_SCRIPTS/container-delete.sh "validator-4"

sleep 3

source $WORKSTATION_SCRIPTS/update-base-image.sh 
source $WORKSTATION_SCRIPTS/update-tools-image.sh 
source $WORKSTATION_SCRIPTS/update-validator-image.sh 

cd $KIRA_WORKSTATION
VALIDATOR_1_EXISTS=$($KIRA_SCRIPTS/container-exists.sh "validator-1" || echo "error")
VALIDATOR_2_EXISTS=$($KIRA_SCRIPTS/container-exists.sh "validator-2" || echo "error")
VALIDATOR_3_EXISTS=$($KIRA_SCRIPTS/container-exists.sh "validator-3" || echo "error")
VALIDATOR_4_EXISTS=$($KIRA_SCRIPTS/container-exists.sh "validator-4" || echo "error")

if [ "$VALIDATOR_1_EXISTS" != "False" ] || [ "$VALIDATOR_2_EXISTS" != "False" ] || [ "$VALIDATOR_3_EXISTS" != "False" ]  || [ "$VALIDATOR_4_EXISTS" != "False" ] ; then
    echo "ERROR: Failed to delete validator-1 container, status-v1: ${VALIDATOR_1_EXISTS}, status-v2: ${VALIDATOR_2_EXISTS}, status-v3: ${VALIDATOR_3_EXISTS}, status-v4: ${VALIDATOR_4_EXISTS}"
    exit 1
fi

VALIDATORS_COUNT=2

echo "INFO: Creating 'validator-1' container..."
rm -fr "${KIRA_STATE}/validator-1"
mkdir -p "${KIRA_STATE}/validator-1"
docker run -d \
 --network="host" \
 --restart=always \
 --name validator-1 \
 -e VALIDATOR_INDEX=1 \
 -e VALIDATORS_COUNT=$VALIDATORS_COUNT \
 -e MONIKER="Local Kira Hub Validator 1" \
 -e P2P_PROXY_PORT=1100 \
 -e RPC_PROXY_PORT=1101 \
 -e LCD_PROXY_PORT=1102 \
 -e RLY_PROXY_PORT=1103 \
 -e EMAIL_NOTIFY="$EMAIL_NOTIFY" \
 -e SMTP_SECRET="$SMTP_SECRET" \
 -e NOTIFICATIONS="$NOTIFICATIONS" \
 -e DEBUG_MODE="$DEBUG_MODE" \
 -e SILENT_MODE="$SILENT_MODE" \
 -e NODE_KEY="node-key-1" \
 -e SIGNING_KEY="signing-1" \
 validator:latest

echo "INFO: Witing for validator-1 to start..."
source $WORKSTATION_SCRIPTS/await-container-init.sh "validator-1" "300" "10"

echo "INFO: Inspecting if validator-1 is running..."
docker exec -it validator-1 sekaid version || echo "ERROR: sekai not found"

echo "INFO: Saving genesis file..."
GENESIS_SOUCE="/root/.sekai/config/genesis.json"
DOCKER_COMMON="/docker/shared/common"
GENESIS_DESTINATION="$DOCKER_COMMON/genesis.json"
mkdir -p $DOCKER_COMMON
rm -f $GENESIS_DESTINATION
docker cp $NAME:$GENESIS_SOUCE $GENESIS_DESTINATION

if [ ! -f "$GENESIS_DESTINATION" ] ; then
    echo "ERROR: Failed to copy genesis file from validator-1"
    exit 1
fi

for ((i=2;i<=$VALIDATORS_COUNT;i++)); do
    echo "INFO: Creating validator-$i container..."
    rm -fr "${KIRA_STATE}/validator-$i"
    mkdir -p "${KIRA_STATE}/validator-$i"
    docker run -d \
     --network="host" \
     --restart=always \
     --name "validator-$i" \
     -e VALIDATOR_INDEX=$i \
     -e VALIDATORS_COUNT=$VALIDATORS_COUNT \
     -e MONIKER="Local Kira Hub Validator $i" \
     -e P2P_PROXY_PORT="${i}100" \
     -e RPC_PROXY_PORT="${i}101" \
     -e LCD_PROXY_PORT="${i}102" \
     -e RLY_PROXY_PORT="${i}103" \
     -e EMAIL_NOTIFY="$EMAIL_NOTIFY" \
     -e SMTP_SECRET="$SMTP_SECRET" \
     -e NOTIFICATIONS="$NOTIFICATIONS" \
     -e DEBUG_MODE="$DEBUG_MODE" \
     -e SILENT_MODE="$SILENT_MODE" \
     -e NODE_KEY="node-key-$i" \
     -e SIGNING_KEY="signing-$i" \
     -v $DOCKER_COMMON:"/common"
     validator:latest

    echo "INFO: Inspecting if validator-$i is running..."
    docker exec -it "validator-$i" sekaid version || echo "ERROR: sekai not found"
done






# success_end file is created when docker startup suceeds

echo "------------------------------------------------"
echo "| FINISHED: KIRA INFRA START v0.0.1            |"
echo "|  ELAPSED: $(($(date -u +%s)-$START_TIME_INFRA)) seconds"
echo "------------------------------------------------"