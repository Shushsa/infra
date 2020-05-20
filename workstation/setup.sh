#!/bin/bash

exec 2>&1
set -e
set -x

# Local Update Shortcut:
# (rm -fv $KIRA_WORKSTATION/setup.sh) && nano $KIRA_WORKSTATION/setup.sh && chmod 777 $KIRA_WORKSTATION/setup.sh

ETC_PROFILE="/etc/profile"
CARGO_ENV="/home/$SUDO_USER/.cargo/env"
BASHRC=~/.bashrc
KIRA_SETUP=/kira/setup
KIRA_INFRA=/kira/infra
KIRA_STATE=/kira/state
KIRA_REGISTRY_PORT=5000
KIRA_REGISTRY="localhost:$KIRA_REGISTRY_PORT"
KIRA_SCRIPTS="${KIRA_INFRA}/common/scripts"
KIRA_IMG="${KIRA_INFRA}/common/img"
KIRA_WORKSTATION="${KIRA_INFRA}/workstation"
KIRA_DOCKER="${KIRA_INFRA}/docker"
KIRA_INFRA_REPO="https://github.com/KiraCore/infra"
GO_VERSION="1.14.2"
NGINX_SERVICED_PATH="/etc/systemd/system/nginx.service.d"
NGINX_CONFIG="/etc/nginx/nginx.conf"
GOROOT="/usr/local/go"
GOPATH="/home/go"
GOBIN="${GOROOT}/bin"
RUSTFLAGS="-Ctarget-feature=+aes,+ssse3"
DOTNET_ROOT="/usr/bin/dotnet"
USER_SHORTCUTS="/home/$SUDO_USER/.local/share/applications"
ROOT_SHORTCUTS="/root/.local/share/applications"
SMTP_SECRET='{"host":"smtp.gmail.com","port":"587","ssl":true,"login":"noreply.example.email@gmail.com","password":"wpzpjrfsfznyeohs"}'

mkdir -p $KIRA_SETUP 
mkdir -p $KIRA_INFRA
mkdir -p $KIRA_STATE
mkdir -p "/home/$SUDO_USER/.cargo"

KIRA_SETUP_ROURCE_ENV="$KIRA_SETUP/source-env-v0.0.2" 
if [ ! -f "$KIRA_SETUP_ROURCE_ENV" ] ; then
    echo "Setting up sourcing of environment variables from $ETC_PROFILE"
    echo "source $ETC_PROFILE" >> $BASHRC
    touch $CARGO_ENV
    echo "source $CARGO_ENV" >> $BASHRC
    touch $KIRA_SETUP_ROURCE_ENV
else
    echo "Environment variables are already beeing sourced from $ETC_PROFILE"
fi

KIRA_SETUP_KIRA_ENV="$KIRA_SETUP/kira-env-v0.0.14" 
if [ ! -f "$KIRA_SETUP_KIRA_ENV" ] ; then
    echo "Setting up kira environment variables"

    PATH="$PATH:$GOBIN:$GOROOT:$GOPATH:/usr/local/bin/CDHelper:/usr/local/bin/AWSHelper"

    echo "KIRA_SETUP=$KIRA_SETUP" >> $ETC_PROFILE
    echo "KIRA_INFRA=$KIRA_INFRA" >> $ETC_PROFILE
    echo "KIRA_STATE=$KIRA_STATE" >> $ETC_PROFILE
    echo "KIRA_SCRIPTS=$KIRA_SCRIPTS" >> $ETC_PROFILE
    echo "KIRA_REGISTRY_PORT=$KIRA_REGISTRY_PORT" >> $ETC_PROFILE
    echo "KIRA_REGISTRY=$KIRA_REGISTRY" >> $ETC_PROFILE
    echo "KIRA_WORKSTATION=$KIRA_WORKSTATION" >> $ETC_PROFILE
    echo "KIRA_DOCKER=$KIRA_DOCKER" >> $ETC_PROFILE
    echo "USER_SHORTCUTS=$USER_SHORTCUTS" >> $ETC_PROFILE
    echo "ROOT_SHORTCUTS=$ROOT_SHORTCUTS" >> $ETC_PROFILE
    echo "NGINX_CONFIG=$NGINX_CONFIG"
    echo "NGINX_SERVICED_PATH=$NGINX_SERVICED_PATH" >> $ETC_PROFILE
    echo "GOROOT=$GOROOT" >> $ETC_PROFILE
    echo "GOPATH=$GOPATH" >> $ETC_PROFILE
    echo "GOBIN=$GOBIN" >> $ETC_PROFILE
    echo "GO111MODULE=on" >> $ETC_PROFILE
    echo "RUSTFLAGS=$RUSTFLAGS" >> $ETC_PROFILE
    echo "DOTNET_ROOT=$DOTNET_ROOT" >> $ETC_PROFILE

    echo "PATH=$PATH" >> $ETC_PROFILE

    source $ETC_PROFILE
    touch $KIRA_SETUP_KIRA_ENV
else
    echo "Kira environment variables were already set"
fi

KIRA_SETUP_CERTS="$KIRA_SETUP/certs-v0.0.3" 
if [ ! -f "$KIRA_SETUP_CERTS" ] ; then
    echo "Installing certificates and package references..."
    apt-get update -y --fix-missing
    apt-get upgrade -y --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages
    apt-get install -y software-properties-common apt-transport-https ca-certificates gnupg curl wget
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
    echo "deb http://archive.ubuntu.com/ubuntu/ bionic universe" | tee /etc/apt/sources.list.d/bionic.list
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google.list
    add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    touch $KIRA_SETUP_CERTS
else
    echo "Certs and refs were already installed."
fi

KIRA_SETUP_BASE_TOOLS="$KIRA_SETUP/base-tools-v0.0.4" 
if [ ! -f "$KIRA_SETUP_BASE_TOOLS" ] ; then
    echo "APT Update, Upgrade and Intall basic tools and dependencies..."
    apt-get update -y --fix-missing
    apt-get upgrade -y --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages
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

KIRA_SETUP_GIT_SIMLINK="$KIRA_SETUP/git-simlink-v0.0.1" 
if [ ! -f "$KIRA_SETUP_GIT_SIMLINK" ] ; then
    echo "Creating GIT simlink and global setup"
    ln -s /usr/bin/git /bin/git || echo "Symlink already Created"
    
    which git
    /usr/bin/git --version
    
    git config --global url.https://github.com/.insteadOf git://github.com/
    touch $KIRA_SETUP_GIT_SIMLINK
else
    echo "Git simlink was already installed."
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
fi

KIRA_SETUP_DOCKER="$KIRA_SETUP/docker-v0.0.1" 
if [ ! -f "$KIRA_SETUP_DOCKER" ] ; then
    echo "Install Docker"
    apt-get update
    apt install docker.io -y
    systemctl enable --now docker
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
    apt update
    apt upgrade
    apt install code -y
    code --version --user-data-dir=~/.config/Code/
    touch $KIRA_SETUP_VSCODE
else
    echo "Visual Studio Code $(code --version --user-data-dir=~/.config/Code/) was already installed."
fi

echo "Updating Infra Repository..."
rm -rfv $KIRA_INFRA
mkdir -p $KIRA_INFRA
git clone --branch "master" $KIRA_INFRA_REPO $KIRA_INFRA
cd $KIRA_INFRA
git describe --all
chmod -R 777 $KIRA_INFRA

KIRA_SETUP_ASMOTOOLS="$KIRA_SETUP/asmodat-automation-tools-v0.0.4" 
if [ ! -f "$KIRA_SETUP_ASMOTOOLS" ] ; then # this ensures that tools are updated only when requested, not when their version changes
    echo "Install Asmodat Automation helper tools"
    ${KIRA_SCRIPTS}/awshelper-update.sh "v0.12.0"
    AWSHelper version
    
    ${KIRA_SCRIPTS}/cdhelper-update.sh "v0.6.3"
    CDHelper version
    touch $KIRA_SETUP_ASMOTOOLS
else
    echo "Asmodat Automation Tools were already installed."
fi

# ensure docker registry exists
if [[ $(${KIRA_SCRIPTS}/container-exists.sh "registry") == "False" ]] ; then
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

KIRA_SETUP_DESKTOP="$KIRA_SETUP/desktop-shortcuts-v0.0.1" 
if [ ! -f "$KIRA_SETUP_DESKTOP" ] ; then
    echo "Installing Desktop Shortcuts"

    USER_START_SHORTCUT=$USER_SHORTCUTS/kira-start.desktop
    rm -f -v $USER_START_SHORTCUT
    cat > $USER_START_SHORTCUT << EOL
[Desktop Entry]
Type=Application
Terminal=true
Name=KIRA-START
Icon=${KIRA_IMG}/kira-core-250.png
Exec=gnome-terminal -e "bash -c '${KIRA_WORKSTATION}/start.sh;$SHELL'"
Categories=Application;
EOL

    touch $KIRA_SETUP_DESKTOP
else
    echo "Desktop shortcuts were already installed"
fi

# curl https://sh.rustup.rs -sSf | sh