#!/bin/bash

exec 2>&1
set -e
start_time="$(date -u +%s)"

# Local Update Shortcut:
# (rm -fv $KIRA_WORKSTATION/setup.sh) && nano $KIRA_WORKSTATION/setup.sh && chmod 777 $KIRA_WORKSTATION/setup.sh

SKIP_UPDATE=$1

[ -z "$SKIP_UPDATE" ] && SKIP_UPDATE="False"

BASHRC=~/.bashrc
ETC_PROFILE="/etc/profile"

source $ETC_PROFILE &> /dev/null

[ "$DEBUG_MODE" == "True" ] && set -x
[ "$DEBUG_MODE" == "False" ] && set +x

echo "------------------------------------------------"
echo "|       STARTED: KIRA INFRA SETUP v0.0.2       |"
echo "|----------------------------------------------|"
echo "|       INFRA BRANCH: $INFRA_BRANCH"
echo "|       SEKAI BRANCH: $SEKAI_BRANCH"
echo "|         INFRA REPO: $INFRA_REPO"
echo "|         SEKAI REPO: $SEKAI_REPO"
echo "| NOTIFICATION EMAIL: $EMAIL_NOTIFY"
echo "|        SKIP UPDATE: $SKIP_UPDATE"
echo "|          KIRA USER: $KIRA_USER"
echo "|_______________________________________________"

[ -z "$INFRA_BRANCH" ] && echo "ERROR: INFRA_BRANCH env was not defined" && exit 1
[ -z "$SEKAI_BRANCH" ] && echo "ERROR: SEKAI_BRANCH env was not defined" && exit 1
[ -z "$INFRA_REPO" ] && echo "ERROR: INFRA_REPO env was not defined" && exit 1
[ -z "$SEKAI_REPO" ] && echo "ERROR: SEKAI_REPO env was not defined" && exit 1
[ -z "$EMAIL_NOTIFY" ] && echo "ERROR: EMAIL_NOTIFY env was not defined" && exit 1
[ -z "$KIRA_USER" ] && echo "ERROR: KIRA_USER env was not defined" && exit 1

mkdir -p /kira && cd /kira

KIRA_INFRA=/kira/infra
KIRA_SEKAI=/kira/sekai
KIRA_SCRIPTS="$KIRA_INFRA/common/scripts"
KIRA_WORKSTATION="$KIRA_INFRA/workstation"
KIRA_MANAGER="/kira/manager"

if [ "$SKIP_UPDATE" == "False" ] ; then
    echo "INFO: Updating Infra..."
    $KIRA_SCRIPTS/git-pull.sh "$INFRA_REPO" "$INFRA_BRANCH" "$KIRA_INFRA"
    $KIRA_SCRIPTS/git-pull.sh "$SEKAI_REPO" "$SEKAI_BRANCH" "$KIRA_SEKAI"
    chmod -R 777 $KIRA_INFRA
    $KIRA_WORKSTATION/setup.sh "True"
elif [ "$SKIP_UPDATE" == "True" ] ; then
    echo "INFO: Skipping Infra Update..."
else
    echo "ERROR: SKIP_UPDATE propoerty is invalid or undefined"
    exit 1
fi

CARGO_ENV="/home/$KIRA_USER/.cargo/env"

KIRA_SETUP=/kira/setup
KIRA_STATE=/kira/state
KIRA_REGISTRY_PORT=5000
KIRA_REGISTRY="localhost:$KIRA_REGISTRY_PORT"

KIRA_IMG="${KIRA_INFRA}/common/img"
KIRA_DOCKER="${KIRA_INFRA}/docker"

GO_VERSION="1.14.2"
NGINX_SERVICED_PATH="/etc/systemd/system/nginx.service.d"
NGINX_CONFIG="/etc/nginx/nginx.conf"
GOROOT="/usr/local/go"
GOPATH="/home/go"
GOBIN="${GOROOT}/bin"
RUSTFLAGS="-Ctarget-feature=+aes,+ssse3"
DOTNET_ROOT="/usr/bin/dotnet"
SOURCES_LIST="/etc/apt/sources.list.d"

mkdir -p $KIRA_SETUP 
mkdir -p $KIRA_INFRA
mkdir -p $KIRA_STATE
mkdir -p "/home/$KIRA_USER/.cargo"
mkdir -p "/home/$KIRA_USER/Desktop"
mkdir -p $SOURCES_LIST
mkdir -p $KIRA_MANAGER
chmod 777 $ETC_PROFILE

${KIRA_SCRIPTS}/cdhelper-update.sh "v0.6.12"
CDHelper version

${KIRA_SCRIPTS}/awshelper-update.sh "v0.12.4"
AWSHelper version

KIRA_SETUP_CERTS="$KIRA_SETUP/certs-v0.0.4" 
if [ ! -f "$KIRA_SETUP_CERTS" ] ; then
    echo "Installing certificates and package references..."
    apt-get update -y --fix-missing
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
    add-apt-repository "deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ bionic universe"
    add-apt-repository "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"
    add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    touch $KIRA_SETUP_CERTS
else
    echo "Certs and refs were already installed."
fi

KIRA_SETUP_KIRA_ENV="$KIRA_SETUP/kira-env-v0.0.24" 
if [ ! -f "$KIRA_SETUP_KIRA_ENV" ] ; then
    echo "Setting up kira environment variables"
    touch $CARGO_ENV

    # remove & disable system crash notifications
    rm -f /var/crash/*
    CDHelper text lineswap --insert="enabled=0" --prefix="enabled=" --path=/etc/default/apport --append-if-found-not=True
    
    CDHelper text lineswap --insert="KIRA_MANAGER=$KIRA_MANAGER" --prefix="KIRA_MANAGER=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="ETC_PROFILE=$ETC_PROFILE" --prefix="ETC_PROFILE=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="KIRA_SETUP=$KIRA_SETUP" --prefix="KIRA_SETUP=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="KIRA_SEKAI=$KIRA_SEKAI" --prefix="KIRA_SEKAI=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="KIRA_INFRA=$KIRA_INFRA" --prefix="KIRA_INFRA=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="KIRA_STATE=$KIRA_STATE" --prefix="KIRA_STATE=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="KIRA_SCRIPTS=$KIRA_SCRIPTS" --prefix="KIRA_SCRIPTS=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="KIRA_REGISTRY_PORT=$KIRA_REGISTRY_PORT" --prefix="KIRA_REGISTRY_PORT=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="KIRA_REGISTRY=$KIRA_REGISTRY" --prefix="KIRA_REGISTRY=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="KIRA_WORKSTATION=$KIRA_WORKSTATION" --prefix="KIRA_WORKSTATION=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
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
    echo "Kira environment variables were already set"
fi

KIRA_SETUP_BASE_TOOLS="$KIRA_SETUP/base-tools-v0.0.4" 
if [ ! -f "$KIRA_SETUP_BASE_TOOLS" ] ; then
    echo "APT Update, Upgrade and Intall basic tools and dependencies..."
    apt-get update -y --fix-missing
    apt-get install -y --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages \
        autoconf \
        automake \
        apt-utils \
        awscli \
        dconf-editor \
        build-essential \
        bind9-host \
        bzip2 \
        coreutils \
        clang \
        cmake \
        dnsutils \
        dpkg-dev \
        ed \
        file \
        gcc \
        g++ \
        git \
        gnupg2 \
        groff \
        htop \
        hashdeep \
        imagemagick \
        iputils-tracepath \
        iputils-ping \
        jq \
        language-pack-en \
        libtool \
        libzip4 \
        libssl1.1 \
        libudev-dev \
        libunwind-dev \
        libusb-1.0-0-dev \
        locales \
        make \
        nano \
        nautilus-admin \
        nginx \
        netbase \
        netcat-openbsd \
        net-tools \
        nodejs \
        node-gyp \
        openssh-client \
        openssh-server \
        pkg-config \
        python \
        patch \
        procps \
        python3 \
        python3-pip \
        rename \
        rsync \
        socat \
        sshfs \
        stunnel \
        subversion \
        syslinux \
        tar \
        telnet \
        tzdata \
        unzip \
        wipe \
        xdotool \
        yarn \
        zip

    # https://linuxhint.com/install_aws_cli_ubuntu/
    aws --version
    touch $KIRA_SETUP_BASE_TOOLS

    #allow to execute scripts just like .exe files with double click
    gsettings set org.gnome.nautilus.preferences executable-text-activation 'launch'
else
    echo "Base tools were already installed."
fi

KIRA_SETUP_NPM="$KIRA_SETUP/npm-v0.0.1"
if [ ! -f "$KIRA_SETUP_NPM" ] ; then
    echo "Intalling NPM..."
    apt-get install -y --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages \
        npm
    npm install -g n
    n stable
    touch $KIRA_SETUP_NPM
else
    echo "NPM $(npm --version) was already installed."
fi

KIRA_SETUP_RUST_TOOLS="$KIRA_SETUP/rust-tools-v0.0.1" 
if [ ! -f "$KIRA_SETUP_RUST_TOOLS" ] ; then
    echo "APT Intall Rust Dependencies..."
    apt-get install -y --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages \
        libc6-dev \
        libbz2-dev \
        libcurl4-openssl-dev \
        libdb-dev \
        libevent-dev \
        libffi-dev \
        libgdbm-dev \
        libglib2.0-dev \
        libgmp-dev \
        libjpeg-dev \
        libkrb5-dev \
        liblzma-dev \
        libmagickcore-dev \
        libmagickwand-dev \
        libmaxminddb-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libpng-dev \
        libpq-dev \
        libreadline-dev \
        libsqlite3-dev \
        libwebp-dev \
        libxml2-dev \
        libxslt-dev \
        libyaml-dev \
        xz-utils \
        zlib1g-dev
    touch $KIRA_SETUP_RUST_TOOLS
else
    echo "Rust tools were already installed."
fi

KIRA_SETUP_DOTNET="$KIRA_SETUP/dotnet-v0.0.6" 
if [ ! -f "$KIRA_SETUP_DOTNET" ] ; then
    echo "Installing .NET"
    wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    dpkg -i packages-microsoft-prod.deb
    apt-get update -y --fix-missing
    apt-get install -y dotnet-runtime-deps-3.1
    apt-get install -y dotnet-runtime-3.1
    apt-get install -y aspnetcore-runtime-3.1
    apt-get install -y dotnet-sdk-2.1
    apt-get install -y dotnet-sdk-3.1
    touch $KIRA_SETUP_DOTNET
else
    echo ".NET $(dotnet --version) was already installed."
    dotnet --list-runtimes
    dotnet --list-sdks
fi

KIRA_SETUP_SYSCTL="$KIRA_SETUP/systemctl-v0.0.1" 
if [ ! -f "$KIRA_SETUP_SYSCTL" ] ; then
    echo "Installing custom systemctl..."
    wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py -O /usr/local/bin/systemctl2
    chmod -v 777 /usr/local/bin/systemctl2
    
    systemctl2 --version
    touch $KIRA_SETUP_SYSCTL
else
    echo "systemctl2 was already installed."
fi

KIRA_SETUP_DOCKER="$KIRA_SETUP/docker-v0.0.1" 
if [ ! -f "$KIRA_SETUP_DOCKER" ] ; then
    echo "Install Docker"
    apt-get update
    apt install docker.io -y
    systemctl2 enable --now docker
    docker -v
    touch $KIRA_SETUP_DOCKER
else
    echo "Docker $(docker -v) was already installed."
fi

KIRA_SETUP_GO="$KIRA_SETUP/go-v$GO_VERSION" 
if [ ! -f "$KIRA_SETUP_GO" ] ; then
    echo "Installing latest go version $GO_VERSION https://golang.org/doc/install ..."
    wget https://dl.google.com/go/go$GO_VERSION.linux-amd64.tar.gz
    tar -C /usr/local -xvf go$GO_VERSION.linux-amd64.tar.gz
    go version
    go env
    touch $KIRA_SETUP_GO
else
    echo "Go $(go version) was already installed."
fi

KIRA_SETUP_NGINX="$KIRA_SETUP/nginx-v0.0.1" 
if [ ! -f "$KIRA_SETUP_NGINX" ] ; then
    echo "Setting up NGINX..."
    cat > $NGINX_CONFIG << EOL
worker_processes 1;
events { worker_connections 512; }
http { 
#server{} 
}
#EOF
EOL

    mkdir -v $NGINX_SERVICED_PATH
    printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" > $NGINX_SERVICED_PATH/override.conf
    
    systemctl2 enable nginx.service
    touch $KIRA_SETUP_NGINX
else
    echo "nginx was already installed."
fi

KIRA_SETUP_CHROME="$KIRA_SETUP/chrome-v0.0.1" 
if [ ! -f "$KIRA_SETUP_CHROME" ] ; then
    echo "Installing Google Chrome..."
    apt-get update -y --fix-missing
    apt install google-chrome-stable -y
    google-chrome --version
    touch $KIRA_SETUP_CHROME
else
    echo "Chrome $(google-chrome --version) was already installed."
fi

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

# ensure docker registry exists
if [[ $(${KIRA_SCRIPTS}/container-exists.sh "registry") != "True" ]] ; then
    echo "Container 'registry' does NOT exist, creating..."
    ${KIRA_SCRIPTS}/container-delete.sh "registry"
docker run -d \
 -p $KIRA_REGISTRY_PORT:$KIRA_REGISTRY_PORT \
 --restart=always \
 --name registry \
 -e REGISTRY_STORAGE_DELETE_ENABLED=true \
 registry:2.7.1
else
    echo "Container 'registry' already exists."
    docker exec -it registry bin/registry --version
fi

docker ps # list containers
docker images ls

echo "Updating Desktop Shortcuts..."
GKSUDO_PATH=/usr/local/bin/gksudo
echo "pkexec env DISPLAY=\$DISPLAY XAUTHORITY=\$XAUTHORITY \$@" > $GKSUDO_PATH
chmod 777 $GKSUDO_PATH

# we must ensure that recovery files can't be destroyed in the update process and cause a deadlock
rm -r -f $KIRA_MANAGER
cp -r $KIRA_WORKSTATION $KIRA_MANAGER

KIRA_MANAGER_SCRIPT=$KIRA_MANAGER/start-manager.sh

echo "gnome-terminal --working-directory=/kira -- bash -c '$KIRA_MANAGER/manager.sh ; $SHELL'" > $KIRA_MANAGER_SCRIPT

chmod -R 777 $KIRA_MANAGER

KIRA_MANAGER_ENTRY="[Desktop Entry]
Type=Application
Terminal=false
Name=KIRA-MANAGER
Icon=${KIRA_IMG}/interchain.png
Exec=gksudo $KIRA_MANAGER_SCRIPT
Categories=Application;"

USER_MANAGER_FAVOURITE=$USER_SHORTCUTS/kira-manager.desktop

cat > $USER_MANAGER_FAVOURITE <<< $KIRA_MANAGER_ENTRY

chmod +x $USER_MANAGER_FAVOURITE

USER_MANAGER_DESKTOP="/home/$KIRA_USER/Desktop/KIRA-MANAGER.desktop"

cat > $USER_MANAGER_DESKTOP <<< $KIRA_MANAGER_ENTRY

chmod +x $USER_MANAGER_DESKTOP 

end_time="$(date -u +%s)"
elapsed="$(($end_time-$start_time))"
echo "INFO: Total of $elapsed seconds elapsed for process"
echo "------------------------------------------------"
echo "|      FINISHED: KIRA INFRA SETUP v0.0.2       |"
echo "------------------------------------------------"
