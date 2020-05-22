
#!/bin/bash

exec 2>&1
set -e
set -x

# Local Update Shortcut:
# (rm -fv $KIRA_WORKSTATION/init.sh) && nano $KIRA_WORKSTATION/init.sh && chmod 777 $KIRA_WORKSTATION/init.sh

BRANCH=$1
REPO=$2

[ -z "$BRANCH" ] && BRANCH="master"
[ -z "$KIRA_INFRA_REPO" ] && KIRA_INFRA_REPO="https://github.com/KiraCore/infra"

KIRA_INFRA=/kira/infra
KIRA_WORKSTATION="${KIRA_INFRA}/workstation"

KIRA_SETUP=/kira/setup
KIRA_SCRIPTS="${KIRA_INFRA}/common/scripts"

mkdir -p $KIRA_INFRA

apt-get update -y --fix-missing
apt-get upgrade -y --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages
apt-get install -y software-properties-common apt-transport-https ca-certificates gnupg curl wget

ln -s /usr/bin/git /bin/git || echo "Symlink already Created"
git --version
git config --global url.https://github.com/.insteadOf git://github.com/

echo "Updating Infra Repository..."
rm -rfv $KIRA_INFRA
mkdir -p $KIRA_INFRA
git clone --branch $BRANCH $KIRA_INFRA_REPO $KIRA_INFRA
cd $KIRA_INFRA
git describe --all --always
chmod -R 777 $KIRA_INFRA

${KIRA_SCRIPTS}/cdhelper-update.sh "v0.6.8"
CDHelper version

$KIRA_WORKSTATION/setup.sh $BRANCH



