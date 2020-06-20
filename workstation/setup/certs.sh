
#!/bin/bash

exec 2>&1
set -e

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null

KIRA_SETUP_CERTS="$KIRA_SETUP/certs-v0.0.4" 
if [ ! -f "$KIRA_SETUP_CERTS" ] ; then
    echo "INFO: Installing certificates and package references..."
    apt-get update -y --fix-missing
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
    add-apt-repository "deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ bionic universe"
    add-apt-repository "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"
    add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    touch $KIRA_SETUP_CERTS
else
    echo "INFO: Certs and refs were already installed."
fi
