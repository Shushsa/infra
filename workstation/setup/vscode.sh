
#!/bin/bash

exec 2>&1
set -e

ETC_PROFILE="/etc/profile"

source $ETC_PROFILE &> /dev/null

[ "$DEBUG_MODE" == "True" ] && set -x
[ "$DEBUG_MODE" == "False" ] && set +x

KIRA_SETUP_VSCODE="$KIRA_SETUP/vscode-v0.0.2" 
if [ ! -f "$KIRA_SETUP_VSCODE" ] ; then
    echo "Installing Visual Studio Code..."
    mkdir -p /usr/code
    apt update -y
    # apt upgrade
    apt install code -y
    code --version --user-data-dir=/usr/code
    touch $KIRA_SETUP_VSCODE
else
    echo "Visual Studio Code $(code --version --user-data-dir=/usr/code) was already installed."
fi
