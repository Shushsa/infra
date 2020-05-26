
#!/bin/bash

exec 2>&1
set -e

# Local Update Shortcut:
# (rm -fv /tmp/init.sh) && nano /tmp/init.sh && chmod 777 /tmp/init.sh

SKIP_UPDATE=$1

[ -z "$SKIP_UPDATE" ] && SKIP_UPDATE="False"

ETC_PROFILE="/etc/profile"

source $ETC_PROFILE &> /dev/null
[ -z "$INFRA_BRANCH" ] && INFRA_BRANCH="master"
[ -z "$SEKAI_BRANCH" ] && SEKAI_BRANCH="master"
[ -z "$EMAIL_NOTIFY" ] && EMAIL_NOTIFY="noreply.example.email@gmail.com"
[ -z "$INFRA_REPO" ] && INFRA_REPO="https://github.com/KiraCore/infra"
[ -z "$SEKAI_REPO" ] && SEKAI_REPO="https://github.com/KiraCore/sekai"
[ ! -z "$SUDO_USER" ] && KIRA_USER=$SUDO_USER

read -p "Provide INFRA reposiotry branch (press ENTER if '$INFRA_BRANCH'): " NEW_INFRA_BRANCH
[ ! -z "$NEW_INFRA_BRANCH" ] && INFRA_BRANCH=$NEW_INFRA_BRANCH

read -p "Provide SEKAI reposiotry branch (press ENTER if '$SEKAI_BRANCH'): " NEW_SEKAI_BRANCH
[ ! -z "$NEW_SEKAI_BRANCH" ] && SEKAI_BRANCH=$NEW_SEKAI_BRANCH

read -p "Provide desired notification email (press ENTER if '$EMAIL_NOTIFY'): " NEW_NOTIFY_EMAIL
[ ! -z "$NEW_NOTIFY_EMAIL" ] && EMAIL_NOTIFY=$NEW_NOTIFY_EMAIL

echo "------------------------------------------------"
echo "|       STARTED: KIRA INFRA INIT v0.0.1        |"
echo "|----------------------------------------------|"
echo "|       INFRA BRANCH: $INFRA_BRANCH"
echo "|       SEKAI BRANCH: $SEKAI_BRANCH"
echo "|         INFRA REPO: $INFRA_REPO"
echo "|         SEKAI REPO: $SEKAI_REPO"
echo "| NOTIFICATION EMAIL: $EMAIL_NOTIFY"
echo "|          KIRA USER: $KIRA_USER"
echo "|_______________________________________________"

read  -d'' -s -n1 -p "Press [ENTER] to confirm or any other key to exit" ACCEPT
[ ! -z $"$ACCEPT" ] && exit 1

KIRA_INFRA=/kira/infra
KIRA_WORKSTATION="${KIRA_INFRA}/workstation"

KIRA_SETUP=/kira/setup
KIRA_SCRIPTS="${KIRA_INFRA}/common/scripts"

mkdir -p $KIRA_INFRA

apt-get update -y
apt-get install -y --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages \
    software-properties-common apt-transport-https ca-certificates gnupg curl wget git

ln -s /usr/bin/git /bin/git || echo "Git symlink already exists"
git --version
git config --global url.https://github.com/.insteadOf git://github.com/

echo "Updating Infra Repository..."
rm -rfv $KIRA_INFRA
mkdir -p $KIRA_INFRA
git clone --branch $INFRA_BRANCH $INFRA_REPO $KIRA_INFRA
cd $KIRA_INFRA
git describe --all --always
chmod -R 777 $KIRA_INFRA

${KIRA_SCRIPTS}/cdhelper-update.sh "v0.6.11"
CDHelper version

CDHelper text lineswap --insert="KIRA_USER=$KIRA_USER" --prefix="KIRA_USER=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="EMAIL_NOTIFY=$EMAIL_NOTIFY" --prefix="EMAIL_NOTIFY=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="INFRA_BRANCH=$INFRA_BRANCH" --prefix="INFRA_BRANCH=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="SEKAI_BRANCH=$SEKAI_BRANCH" --prefix="SEKAI_BRANCH=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="INFRA_REPO=$INFRA_REPO" --prefix="INFRA_REPO=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="SEKAI_REPO=$SEKAI_REPO" --prefix="SEKAI_REPO=" --path=$ETC_PROFILE --append-if-found-not=True

cd /kira
source $KIRA_WORKSTATION/setup.sh "True"

echo "------------------------------------------------"
echo "|       FINISHED: KIRA INFRA INIT v0.0.1       |"
echo "------------------------------------------------"

