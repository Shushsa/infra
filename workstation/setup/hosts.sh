
#!/bin/bash

exec 2>&1
set -e

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null
if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi

KIRA_SETUP_HOSTS="$KIRA_SETUP/hosts-v0.0.1-$KIRA_REGISTRY_NAME" 
if [ ! -f "$KIRA_SETUP_HOSTS" ] ; then
    echo "INFO: Setting up default hosts..."
    HOSTS_PATH="/etc/hosts"
    CDHelper text lineswap --insert="127.0.0.1 localhost $KIRA_REGISTRY_NAME" --prefix="127.0.0.1" --path=$HOSTS_PATH --append-if-found-not=True --silent=$SILENT_MODE
    touch $KIRA_SETUP_HOSTS
else
    echo "INFO: Default host names were already defined"
fi
