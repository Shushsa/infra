
#!/bin/bash

exec 2>&1
set -e

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null

KIRA_SETUP_CHROME="$KIRA_SETUP/chrome-v0.0.1" 
if [ ! -f "$KIRA_SETUP_CHROME" ] ; then
    echo "INFO: Installing Google Chrome..."
    apt-get update -y --fix-missing
    apt install google-chrome-stable -y || FAILED="True"
    [ "$FAILED" == "True" ] && \
        echo "Failed to install google chrome, retry in 5 seconds..." && \
        sleep 5 && \
        apt install google-chrome-stable -y
    google-chrome --version
    touch $KIRA_SETUP_CHROME
else
    echo "INFO: Chrome $(google-chrome --version) was already installed"
fi
