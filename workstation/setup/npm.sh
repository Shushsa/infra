
#!/bin/bash

exec 2>&1
set -e

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null
if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi

KIRA_SETUP_NPM="$KIRA_SETUP/npm-v0.0.1"
if [ ! -f "$KIRA_SETUP_NPM" ] ; then
    echo "INFO: Intalling NPM..."
    apt-get install -y --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages \
        npm
    npm install -g n
    n stable
    touch $KIRA_SETUP_NPM
else
    echo "INFO: NPM $(npm --version) was already installed."
fi

$KIRA_SCRIPTS/progress-touch.sh "+1"