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
for ((i=1;i<=$MAX_VALIDATORS_COUNT;i++)); do
    $KIRA_SCRIPTS/container-delete.sh "validator-$i"

    VALIDATOR_EXISTS=$($KIRA_SCRIPTS/container-exists.sh "validator-$i" || echo "error")

    if [ "$VALIDATOR_EXISTS" != "False" ] ; then
        echo "ERROR: Failed to delete validator-$i container, status: ${VALIDATOR_EXISTS}"
        exit 1
    fi
done

source $WORKSTATION_SCRIPTS/update-base-image.sh 
source $WORKSTATION_SCRIPTS/update-tools-image.sh 
source $WORKSTATION_SCRIPTS/update-validator-image.sh 

cd $KIRA_WORKSTATION

docker network rm kiranet || echo "Failed to remove kira network"
docker network create --subnet=$KIRA_VALIDATORS_SUBNET kiranet

GENESIS_SOUCE="/root/.sekaid/config/genesis.json"
GENESIS_DESTINATION="$DOCKER_COMMON/genesis.json"
mkdir -p $DOCKER_COMMON
rm -f $GENESIS_DESTINATION

SEEDS=""

for ((i=1;i<=$VALIDATORS_COUNT;i++)); do
    echo "INFO: Creating validator-$i container..."
    NODE_HOSTNAME="validator-$i.local"
    rm -fr "${KIRA_STATE}/validator-$i"
    mkdir -p "${KIRA_STATE}/validator-$i"
    docker run -d \
     --restart=always \
     --name "validator-$i" \
     --network kiranet \
     --ip "101.0.1.$i" \
     --hostname $NODE_HOSTNAME \
     -e VALIDATOR_INDEX=$i \
     -e VALIDATORS_COUNT=$VALIDATORS_COUNT \
     -e MONIKER="Local Kira Hub Validator $i" \
     -e P2P_PROXY_PORT="10000" \
     -e RPC_PROXY_PORT="10001" \
     -e LCD_PROXY_PORT="10002" \
     -e RLY_PROXY_PORT="10003" \
     -e EMAIL_NOTIFY="$EMAIL_NOTIFY" \
     -e SMTP_SECRET="$SMTP_SECRET" \
     -e NOTIFICATIONS="$NOTIFICATIONS" \
     -e DEBUG_MODE="$DEBUG_MODE" \
     -e SILENT_MODE="$SILENT_MODE" \
     -e SEEDS="$SEEDS" \
     -v $DOCKER_COMMON:"/common" \
     validator:latest

    # NOTE: Following actions destroy $i variable so VALIDATOR_INDEX is needed
    echo "INFO: Witing for validator-$i to start..."
    VALIDATOR_INDEX=$i
    sleep 10
    source $WORKSTATION_SCRIPTS/await-container-init.sh "validator-$i" "300" "10"

    echo "INFO: Inspecting if validator-$VALIDATOR_INDEX is running..."
    SEKAID_VERSION=$(docker exec -it "validator-$VALIDATOR_INDEX" sekaid version || echo "error")
    if [ "$SEKAID_VERSION" == "error" ] ; then 
        echo "ERROR: sekaid was NOT found" 
        exit 1
    else 
        echo "SUCCESS: sekaid $SEKAID_VERSION was found" 
    fi 

    if [ $VALIDATOR_INDEX -eq 1 ] ; then
        echo "INFO: Saving genesis file..."
        docker cp $NAME:$GENESIS_SOUCE $GENESIS_DESTINATION
        
        if [ ! -f "$GENESIS_DESTINATION" ] ; then
            echo "ERROR: Failed to copy genesis file from validator-$VALIDATOR_INDEX"
            exit 1
        fi
    fi

    NODE_ID=$(echo $(docker exec -it "validator-$VALIDATOR_INDEX" sekaid tendermint show-node-id || echo "error") | xargs)
    SEEDS="${NODE_ID}@${NODE_HOSTNAME}"

    # we have to recover the index back before progressing
    i=$VALIDATOR_INDEX
    echo "SUCCESS: validator-$i is up and running, seed: $SEEDS"
done

# success_end file is created when docker startup suceeds
echo "------------------------------------------------"
echo "| FINISHED: KIRA INFRA START v0.0.1            |"
echo "|  ELAPSED: $(($(date -u +%s)-$START_TIME_INFRA)) seconds"
echo "------------------------------------------------"