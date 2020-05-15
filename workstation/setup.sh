#!/bin/bash

exec 2>&1
set -e
set -x

# Local Update Shortcut:
# (rm -fv ./setup.sh) && nano ./setup.sh && chmod 777 ./setup.sh

ETC_PROFILE="/etc/profile"
CARGO_ENV="/home/$SUDO_USER/.cargo/env"
BASHRC=~/.bashrc
KIRA_SETUP=/kira/setup
KIRA_INFRA=/kira/infra
KIRA_INFRA_SCRIPTS="${KIRA_INFRA}/docker/base-image/scripts"
KIRA_INFRA_REPO="https://github.com/KiraCore/infra"
GO_VERSION="1.14.2"

mkdir -p $KIRA_SETUP 
mkdir -p $KIRA_INFRA 
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

KIRA_SETUP_KIRA_ENV="$KIRA_SETUP/kira-env-v0.0.4" 
if [ ! -f "$KIRA_SETUP_KIRA_ENV" ] ; then
    echo "Setting up kira environment variables"
    echo "KIRA_SETUP=$KIRA_SETUP" >> $ETC_PROFILE
    echo "KIRA_INFRA=$KIRA_INFRA" >> $ETC_PROFILE
    echo "KIRA_INFRA_SCRIPTS=$KIRA_INFRA_SCRIPTS" >> $ETC_PROFILE
    touch $KIRA_SETUP_KIRA_ENV
else
    echo "Kira environment variables were already set"
fi

KIRA_SETUP_ENV_GO="$KIRA_SETUP/env-go-v0.0.2" 
if [ ! -f "$KIRA_SETUP_ENV_GO" ] ; then
    echo "Golang environment variables setup"
    GOROOT="/usr/local/go"
    GOPATH="/home/go"
    GOBIN="${GOROOT}/bin"
    PATH="$PATH:$GOBIN:$GOROOT:$GOPATH"

    echo "GOROOT=$GOROOT" >> $ETC_PROFILE
    echo "GOPATH=$GOPATH" >> $ETC_PROFILE
    echo "GOBIN=$GOBIN" >> $ETC_PROFILE
    echo "GO111MODULE=on" >> $ETC_PROFILE
    echo "PATH=$PATH" >> $ETC_PROFILE
    source $ETC_PROFILE
    touch $KIRA_SETUP_ENV_GO
else
    echo "Go environment variables such as bin($GOBIN) and path were already set"
fi

KIRA_SETUP_CERTS="$KIRA_SETUP/certs-v0.0.3" 
if [ ! -f "$KIRA_SETUP_CERTS" ] ; then
    echo "Installing certificates and package references..."
    apt-get -y update
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

KIRA_SETUP_BASE_TOOLS="$KIRA_SETUP/base-tools-v0.0.2" 
if [ ! -f "$KIRA_SETUP_BASE_TOOLS" ] ; then
    echo "APT Update, Upgrade and Intall basic tools and dependencies..."
    apt-get update
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

KIRA_SETUP_DOTNET="$KIRA_SETUP/dotnet-v0.0.2" 
if [ ! -f "$KIRA_SETUP_DOTNET" ] ; then
    echo "Installing .NET"
    wget -q https://packages.microsoft.com/config/ubuntu/19.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    dpkg -i packages-microsoft-prod.deb
    apt-get update
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

KIRA_SETUP_CHROME="$KIRA_SETUP/chrome-v0.0.1" 
if [ ! -f "$KIRA_SETUP_CHROME" ] ; then
    echo "Install Google Chrome"
    apt-get update
    apt install google-chrome-stable -y
    google-chrome --version
    touch $KIRA_SETUP_CHROME
else
    echo "Chrome $(google-chrome --version) was already installed."
fi

KIRA_SETUP_VSCODE="$KIRA_SETUP/vscode-v0.0.2" 
if [ ! -f "$KIRA_SETUP_VSCODE" ] ; then
    echo "Install Visual Studio Code"
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
chmod -Rv $KIRA_INFRA

KIRA_SETUP_ASMOTOOLS="$KIRA_SETUP/asmodat-automation-tools-v0.0.1" 
if [ ! -f "$KIRA_SETUP_ASMOTOOLS" ] ; then
    echo "Install Asmodat Automation helper tools"
    ${KIRA_INFRA_SCRIPTS}/awshelper-update-v0.0.1.sh "v0.12.0"
    AWSHelper version
    
    ${KIRA_INFRA_SCRIPTS}/cdhelper-update-v0.0.1.sh "v0.6.0"
    CDHelper version
    touch $KIRA_SETUP_ASMOTOOLS
else
    echo "Asmodat Automation Tools were already installed."
fi

