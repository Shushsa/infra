
#!/bin/bash

exec 2>&1
set -e

BASHRC=~/.bashrc
ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null
if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi

CARGO_ENV="/home/$KIRA_USER/.cargo/env"

KIRA_STATE=/kira/state
KIRA_REGISTRY_PORT=5001
KIRA_REGISTRY_NAME="kira-local.docker.reg"
KIRA_REGISTRY="$KIRA_REGISTRY_NAME:$KIRA_REGISTRY_PORT"

KIRA_IMG="${KIRA_INFRA}/common/img"
KIRA_DOCKER="${KIRA_INFRA}/docker"
WORKSTATION_SCRIPTS=$"$KIRA_WORKSTATION/scripts"

GO_VERSION="1.14.2"
NGINX_SERVICED_PATH="/etc/systemd/system/nginx.service.d"
NGINX_CONFIG="/etc/nginx/nginx.conf"
GOROOT="/usr/local/go"
GOPATH="/home/go"
GOBIN="${GOROOT}/bin"
RUSTFLAGS="-Ctarget-feature=+aes,+ssse3"
DOTNET_ROOT="/usr/bin/dotnet"
SOURCES_LIST="/etc/apt/sources.list.d"

mkdir -p $KIRA_STATE
mkdir -p "/home/$KIRA_USER/.cargo"
mkdir -p "/home/$KIRA_USER/Desktop"
mkdir -p $SOURCES_LIST

KIRA_SETUP_KIRA_ENV="$KIRA_SETUP/kira-env-v0.0.29" 
if [ ! -f "$KIRA_SETUP_KIRA_ENV" ] ; then
    echo "INFO: Setting up kira environment variables"
    touch $CARGO_ENV

    # remove & disable system crash notifications
    rm -f /var/crash/*
    CDHelper text lineswap --insert="enabled=0" --prefix="enabled=" --path=/etc/default/apport --append-if-found-not=True

    CDHelper text lineswap --insert="WORKSTATION_SCRIPTS=$WORKSTATION_SCRIPTS" --prefix="WORKSTATION_SCRIPTS=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="SOURCES_LIST=$SOURCES_LIST" --prefix="SOURCES_LIST=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="GO_VERSION=$GO_VERSION" --prefix="GO_VERSION=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="KIRA_IMG=$KIRA_IMG" --prefix="KIRA_IMG=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="ETC_PROFILE=$ETC_PROFILE" --prefix="ETC_PROFILE=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="KIRA_STATE=$KIRA_STATE" --prefix="KIRA_STATE=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="KIRA_REGISTRY_PORT=$KIRA_REGISTRY_PORT" --prefix="KIRA_REGISTRY_PORT=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="KIRA_REGISTRY_NAME=$KIRA_REGISTRY_NAME" --prefix="KIRA_REGISTRY_NAME=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="KIRA_REGISTRY=$KIRA_REGISTRY" --prefix="KIRA_REGISTRY=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="KIRA_DOCKER=$KIRA_DOCKER" --prefix="KIRA_DOCKER=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="NGINX_CONFIG=$NGINX_CONFIG" --prefix="NGINX_CONFIG=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="NGINX_SERVICED_PATH=$NGINX_SERVICED_PATH" --prefix="NGINX_SERVICED_PATH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="GOROOT=$GOROOT" --prefix="GOROOT=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="GOPATH=$GOPATH" --prefix="GOPATH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="GOBIN=$GOBIN" --prefix="GOBIN=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="GO111MODULE=on" --prefix="GO111MODULE=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="RUSTFLAGS=$RUSTFLAGS" --prefix="RUSTFLAGS=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="DOTNET_ROOT=$DOTNET_ROOT" --prefix="DOTNET_ROOT=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="PATH=$PATH" --prefix="PATH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE

    source $ETC_PROFILE &> /dev/null
    CDHelper text lineswap --insert="PATH=$PATH:$GOPATH" --prefix="PATH=" --and-contains-not=":$GOPATH" --path=$ETC_PROFILE --silent=$SILENT_MODE
    source $ETC_PROFILE &> /dev/null
    CDHelper text lineswap --insert="PATH=$PATH:$GOROOT" --prefix="PATH=" --and-contains-not=":$GOROOT" --path=$ETC_PROFILE --silent=$SILENT_MODE
    source $ETC_PROFILE &> /dev/null
    CDHelper text lineswap --insert="PATH=$PATH:$GOBIN" --prefix="PATH=" --and-contains-not=":$GOBIN" --path=$ETC_PROFILE --silent=$SILENT_MODE
    source $ETC_PROFILE
    chmod 777 $ETC_PROFILE

    CDHelper text lineswap --insert="source $ETC_PROFILE" --prefix="source $ETC_PROFILE" --path=$BASHRC --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="source $CARGO_ENV" --prefix="source $CARGO_ENV" --path=$BASHRC --append-if-found-not=True --silent=$SILENT_MODE
    chmod 777 $BASHRC
    
    touch $KIRA_SETUP_KIRA_ENV
else
    echo "INFO: Kira environment variables were already set"
fi

