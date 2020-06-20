
#!/bin/bash

exec 2>&1
set -e

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null

KIRA_SETUP_RUST_TOOLS="$KIRA_SETUP/rust-tools-v0.0.1" 
if [ ! -f "$KIRA_SETUP_RUST_TOOLS" ] ; then
    echo "INFO: Intalling Rust Dependencies..."
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
    echo "INFO: Rust tools were already installed"
fi

$KIRA_SCRIPTS/progress-touch.sh "+1"