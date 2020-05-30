
#!/bin/bash

exec 2>&1
set -e

# Local Update Shortcut:
# (rm -fv /tmp/init.sh) && nano /tmp/init.sh && chmod 777 /tmp/init.sh

ETC_PROFILE="/etc/profile"

source $ETC_PROFILE &> /dev/null

[ -z "$INFRA_BRANCH" ] && INFRA_BRANCH="master"
[ -z "$SEKAI_BRANCH" ] && SEKAI_BRANCH="master"
[ -z "$EMAIL_NOTIFY" ] && EMAIL_NOTIFY="noreply.example.email@gmail.com"
[ -z "$SMTP_LOGIN" ] && SMTP_LOGIN="noreply.example.email@gmail.com"
[ -z "$SMTP_PASSWORD" ] && SMTP_PASSWORD="wpzpjrfsfznyeohs"
[ -z "$INFRA_REPO" ] && INFRA_REPO="https://github.com/KiraCore/infra"
[ -z "$SEKAI_REPO" ] && SEKAI_REPO="https://github.com/KiraCore/sekai"
[ -z "$SEKAI_REPO_SSH" ] && SEKAI_REPO_SSH="git@github.com:KiraCore/sekai.git"
[ -z "$INFRA_REPO_SSH" ] && INFRA_REPO_SSH="git@github.com:KiraCore/infra.git"
[ ! -z "$SUDO_USER" ] && KIRA_USER=$SUDO_USER
[ -z "$KIRA_USER" ] && KIRA_USER=$USER

SSH_PATH=/home/root/.ssh
mkdir -p $SSH_PATH
chmod 700 $SSH_PATH

SSH_KEY_PUB_PATH=$SSH_PATH/id_rsa.pub
SSH_KEY_PRIV_PATH=$SSH_PATH/id_rsa
if [ ! -f $SSH_KEY_PRIV_PATH ] ; then
    ssh-keygen -q -t rsa -N '' -f $SSH_KEY_PRIV_PATH 2>/dev/null <<< y >/dev/null
    chmod 600 $SSH_KEY_PRIV_PATH
fi

ssh-keygen -y -f $SSH_KEY_PRIV_PATH > $SSH_KEY_PUB_PATH
chmod 644 $SSH_KEY_PUB_PATH
SSK_KEY_PUB=$(cat $SSH_KEY_PUB_PATH)

read -p "Provide INFRA reposiotry branch (press ENTER if '$INFRA_BRANCH'): " NEW_INFRA_BRANCH
[ ! -z "$NEW_INFRA_BRANCH" ] && INFRA_BRANCH=$NEW_INFRA_BRANCH

read -p "Provide SEKAI reposiotry branch (press ENTER if '$SEKAI_BRANCH'): " NEW_SEKAI_BRANCH
[ ! -z "$NEW_SEKAI_BRANCH" ] && SEKAI_BRANCH=$NEW_SEKAI_BRANCH

read -p "Provide desired notification email (press ENTER if '$EMAIL_NOTIFY'): " NEW_NOTIFY_EMAIL
[ ! -z "$NEW_NOTIFY_EMAIL" ] && EMAIL_NOTIFY=$NEW_NOTIFY_EMAIL

read -p "Provide Gmail SMTP login (press ENTER if '$SMTP_LOGIN'): " NEW_SMTP_LOGIN
[ ! -z "$NEW_SMTP_LOGIN" ] && SMTP_LOGIN=$NEW_SMTP_LOGIN

read -p "Provide Gmail SMTP password (press ENTER if '$SMTP_PASSWORD'): " NEW_SMTP_PASSWORD
[ ! -z "$NEW_SMTP_PASSWORD" ] && SMTP_PASSWORD=$NEW_SMTP_PASSWORD

echo "Your public SSH Key:"
echo "$SSK_KEY_PUB"

read -p "Provide your PRIVATE git SSH key or (press ENTER if above): " NEW_SSH_KEY
if [ ! -z "$NEW_SSH_KEY" ] ; then
    echo $NEW_SSH_KEY > $SSH_KEY_PRIV_PATH
    ssh-keygen -y -f $SSH_KEY_PRIV_PATH > $SSH_KEY_PUB_PATH
    chmod 600 $SSH_KEY_PRIV_PATH
    chmod 644 $SSH_KEY_PUB_PATH
    SSK_KEY_PUB=$(cat $SSH_KEY_PUB_PATH)
fi

echo "------------------------------------------------"
echo "|       STARTED: KIRA INFRA INIT v0.0.1        |"
echo "|----------------------------------------------|"
echo "|       INFRA BRANCH: $INFRA_BRANCH"
echo "|       SEKAI BRANCH: $SEKAI_BRANCH"
echo "|         INFRA REPO: $INFRA_REPO"
echo "|         SEKAI REPO: $SEKAI_REPO"
echo "| NOTIFICATION EMAIL: $EMAIL_NOTIFY"
echo "|         SMTP LOGIN: $SMTP_LOGIN"
echo "|      SMTP PASSWORD: $SMTP_PASSWORD"
echo "|          KIRA USER: $KIRA_USER"
echo "| PUBLIC GIT SSH KEY: $(echo $SSK_KEY_PUB | head -c 24)...$(echo $SSK_KEY_PUB | tail -c 24)"
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

CDHelper text lineswap --insert="SMTP_LOGIN=$SMTP_LOGIN" --prefix="SMTP_LOGIN=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="SMTP_PASSWORD=$SMTP_PASSWORD" --prefix="SMTP_PASSWORD=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="SMTP_SECRET={\"host\":\"smtp.gmail.com\",\"port\":\"587\",\"ssl\":true,\"login\":\"$SMTP_LOGIN\",\"password\":\"$SMTP_PASSWORD\"}" --prefix="SMTP_SECRET=" --path=$ETC_PROFILE --append-if-found-not=True

CDHelper text lineswap --insert="SSH_KEY_PRIV_PATH=$SSH_KEY_PRIV_PATH" --prefix="SSH_KEY_PRIV_PATH=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="KIRA_USER=$KIRA_USER" --prefix="KIRA_USER=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="USER_SHORTCUTS=/home/$KIRA_USER/.local/share/applications" --prefix="USER_SHORTCUTS=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="EMAIL_NOTIFY=$EMAIL_NOTIFY" --prefix="EMAIL_NOTIFY=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="INFRA_BRANCH=$INFRA_BRANCH" --prefix="INFRA_BRANCH=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="SEKAI_BRANCH=$SEKAI_BRANCH" --prefix="SEKAI_BRANCH=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="INFRA_REPO=$INFRA_REPO" --prefix="INFRA_REPO=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="SEKAI_REPO=$SEKAI_REPO" --prefix="SEKAI_REPO=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="SEKAI_REPO_SSH=$SEKAI_REPO_SSH" --prefix="SEKAI_REPO_SSH=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="INFRA_REPO_SSH=$INFRA_REPO_SSH" --prefix="INFRA_REPO_SSH=" --path=$ETC_PROFILE --append-if-found-not=True

cd /kira
source $KIRA_WORKSTATION/setup.sh "True"

echo "------------------------------------------------"
echo "|       FINISHED: KIRA INFRA INIT v0.0.1       |"
echo "------------------------------------------------"

