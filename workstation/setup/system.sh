
#!/bin/bash

exec 2>&1
set -e

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null
if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi

KIRA_SETUP_FILE="$KIRA_SETUP/system-v0.0.1" 
if [ ! -f "$KIRA_SETUP_FILE" ] ; then
    echo "INFO: Setting up system pre-requisites..."
    CDHelper text lineswap --insert="* hard nofile 999999" --prefix="* hard nofile" --path="/etc/security/limits.conf" --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="* soft nofile 999999" --prefix="* soft nofile" --path="/etc/security/limits.conf" --append-if-found-not=True --silent=$SILENT_MODE
    touch $KIRA_SETUP_FILE
else
    echo "INFO: Your system has all pre-requisites set"
fi