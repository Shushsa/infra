
#!/bin/bash

exec 2>&1
set -e

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null

KIRA_SETUP_DOTNET="$KIRA_SETUP/dotnet-v0.0.6" 
if [ ! -f "$KIRA_SETUP_DOTNET" ] ; then
    echo "INFO: Installing .NET"
    wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    dpkg -i packages-microsoft-prod.deb
    apt-get update -y --fix-missing
    apt-get install -y dotnet-runtime-deps-3.1
    apt-get install -y dotnet-runtime-3.1
    apt-get install -y aspnetcore-runtime-3.1
    apt-get install -y dotnet-sdk-3.1
    touch $KIRA_SETUP_DOTNET
else
    echo "INFO: .NET $(dotnet --version) was already installed"
    dotnet --list-runtimes
    dotnet --list-sdks
fi

$KIRA_SCRIPTS/progress-touch.sh "+1"
