#!/bin/bash

exec 2>&1
set -e
set -x

# Local Update
# (rm -fv $KIRA_INFRA/docker/base-image/container/deployment.sh) && nano $KIRA_INFRA/docker/base-image/container/deployment.sh

apt-get update -y --fix-missing
apt-get upgrade -y --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages
apt-get install -y software-properties-common apt-transport-https ca-certificates gnupg curl wget

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
echo "deb http://archive.ubuntu.com/ubuntu/ bionic universe" | tee /etc/apt/sources.list.d/bionic.list
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google.list
add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"

echo "APT Update, Upfrade and Intall..."
apt-get update -y --fix-missing
apt-get upgrade -y --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages
apt-get install -y --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages \
    autoconf \
    automake \
    apt-utils \
    awscli \
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
    yarn \
    zip

# https://linuxhint.com/install_aws_cli_ubuntu/
aws --version
