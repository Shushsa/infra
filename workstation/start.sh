#!/bin/bash

exec 2>&1
set -e
set -x

# Local Update Shortcut:
# (rm -fv $KIRA_WORKSTATION/start.sh) && nano $KIRA_WORKSTATION/start.sh && chmod 777 $KIRA_WORKSTATION/start.sh


echo "Updating base image..."
$KIRA_WORKSTATION/update-image "$KIRA_INFRA/docker/base-image" "base-image" "latest"

echo "Updating tools image..."
$KIRA_WORKSTATION/tools-image "$KIRA_INFRA/docker/tools-image" "tools-image" "latest"

echo "All imags were updated, starting validator node..."
#$KIRA_WORKSTATION/validator "$KIRA_INFRA/docker/validator" "validator" "latest"