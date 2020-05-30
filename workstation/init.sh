
#!/bin/bash

exec 2>&1
set -e

# Local Update Shortcut:
# (rm -fv /tmp/init.sh) && nano /tmp/init.sh && chmod 777 /tmp/init.sh

SKIP_UPDATE=$1

[ -z "$SKIP_UPDATE" ] && SKIP_UPDATE="False"

ETC_PROFILE="/etc/profile"

source $ETC_PROFILE &> /dev/null

if [ -z "$DEBUG_MODE" ] ; then
    DEBUG_MODE="False"
    SILENT_MODE="True"
fi

if [ "$SKIP_UPDATE" == "False" ] ; then
    read  -d'' -s -n1 -p "Press [Y]es/[N]o is you want to run in debug mode (press [⏎] if '$DEBUG_MODE'): " NEW_DEBUG_MODE
    if [ $"${NEW_DEBUG_MODE,,}" == "y" ] ; then
        DEBUG_MODE="True"
        SILENT_MODE="False"
    elif [ $"${NEW_DEBUG_MODE,,}" == "n" ]  ; then
        DEBUG_MODE="False"
        SILENT_MODE="True"
    fi
fi

[ "$DEBUG_MODE" == "True" ] && set -x
[ "$DEBUG_MODE" == "False" ] && set +x

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
[ -z "$NOTIFICATIONS" ] && NOTIFICATIONS="False"


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
SSH_KEY_PUB=$(cat $SSH_KEY_PUB_PATH)
SSH_KEY_PRV=$(cat $SSH_KEY_PRIV_PATH)
SSH_KEY_PUB_SHORT=$(echo $SSH_KEY_PUB | head -c 24)...$(echo $SSH_KEY_PUB | tail -c 24)

if [ "$SKIP_UPDATE" == "False" ] ; then
    read -p "Type INFRA reposiotry branch (press [⏎] if '$INFRA_BRANCH'): " NEW_INFRA_BRANCH
    [ ! -z "$NEW_INFRA_BRANCH" ] && INFRA_BRANCH=$NEW_INFRA_BRANCH
else
    read -p "Type SEKAI reposiotry branch (press [⏎] if '$SEKAI_BRANCH'): " NEW_SEKAI_BRANCH
    [ ! -z "$NEW_SEKAI_BRANCH" ] && SEKAI_BRANCH=$NEW_SEKAI_BRANCH
    
    read  -d'' -s -n1 -p "Press [Y]es/[N]o to receive notifications (press [⏎] if '$NOTIFICATIONS'): " NEW_NOTIFICATIONS
    if [ $"${NEW_NOTIFICATIONS,,}" == "y" ] ; then
        NOTIFICATIONS="True"
    elif [ $"${NEW_NOTIFICATIONS,,}" == "n" ] ; then
        NOTIFICATIONS="False"
    fi
    
    if [ "$NOTIFICATIONS" == "True" ] ; then
        read -p "Type desired notification email (press [⏎] if '$EMAIL_NOTIFY'): " NEW_NOTIFY_EMAIL
        [ ! -z "$NEW_NOTIFY_EMAIL" ] && EMAIL_NOTIFY=$NEW_NOTIFY_EMAIL
        
        read -p "Type Gmail SMTP login (press [⏎] if '$SMTP_LOGIN'): " NEW_SMTP_LOGIN
        [ ! -z "$NEW_SMTP_LOGIN" ] && SMTP_LOGIN=$NEW_SMTP_LOGIN
        
        read -p "Type Gmail SMTP password (press [⏎] if '$SMTP_PASSWORD'): " NEW_SMTP_PASSWORD
        [ ! -z "$NEW_SMTP_PASSWORD" ] && SMTP_PASSWORD=$NEW_SMTP_PASSWORD
    fi
    
    echo "Your current public SSH Key:"
    echo -e "\e[33;1m$SSH_KEY_PUB\e[0m"
    
    read -p "Input your PRIVATE git SSH key or (press [⏎] if above PUB key): " NEW_SSH_KEY
    if [ ! -z "$NEW_SSH_KEY" ] ; then
        echo $NEW_SSH_KEY > $SSH_KEY_PRIV_PATH
        ssh-keygen -y -f $SSH_KEY_PRIV_PATH > $SSH_KEY_PUB_PATH
        chmod 600 $SSH_KEY_PRIV_PATH
        chmod 644 $SSH_KEY_PUB_PATH
        SSH_KEY_PUB=$(cat $SSH_KEY_PUB_PATH)
        SSH_KEY_PRV=$(cat $SSH_KEY_PRIV_PATH)
        SSH_KEY_PUB_SHORT=$(echo $SSH_KEY_PUB | head -c 24)...$(echo $SSH_KEY_PUB | tail -c 24)
    
        echo "Your new public SSH Key:"
        echo -e "\e[32;1m$SSH_KEY_PUB\e[0m"
    fi

    echo -e "\e[33;1m------------------------------------------------"
    echo "|       STARTED: KIRA INFRA INIT v0.0.2        |"
    echo "|----------------------------------------------|"
    echo "|         DEBUG MODE: $DEBUG_MODE"
    echo "|       INFRA BRANCH: $INFRA_BRANCH"
    echo "|       SEKAI BRANCH: $SEKAI_BRANCH"
    echo "|         INFRA REPO: $INFRA_REPO"
    echo "|         SEKAI REPO: $SEKAI_REPO"
    echo "|      NOTIFICATIONS: $NOTIFICATIONS"
    echo "| NOTIFICATION EMAIL: $EMAIL_NOTIFY"
    echo "|         SMTP LOGIN: $SMTP_LOGIN"
    echo "|      SMTP PASSWORD: $SMTP_PASSWORD"
    echo "|          KIRA USER: $KIRA_USER"
    echo "| PUBLIC GIT SSH KEY: $SSH_KEY_PUB_SHORT"
    echo -e "------------------------------------------------\e[0m"
    
    read  -d'' -s -n1 -p "Press [⏎] to confirm or any other key to exit: " ACCEPT
    [ ! -z $"$ACCEPT" ] && exit 1
fi

KIRA_INFRA=/kira/infra
KIRA_WORKSTATION="${KIRA_INFRA}/workstation"

KIRA_SETUP=/kira/setup
KIRA_SCRIPTS="${KIRA_INFRA}/common/scripts"

mkdir -p $KIRA_INFRA

echo "INFO: Updating packages..."
apt-get update -y > /dev/null
apt-get install -y --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages \
    software-properties-common apt-transport-https ca-certificates gnupg curl wget git > /dev/null

ln -s /usr/bin/git /bin/git || echo "WARNING: Git symlink already exists"

echo "INFO: Updating Infra Repository..."
rm -rfv $KIRA_INFRA
mkdir -p $KIRA_INFRA
git clone --branch $INFRA_BRANCH $INFRA_REPO $KIRA_INFRA
cd $KIRA_INFRA
git describe --all --always
chmod -R 777 $KIRA_INFRA
cd /kira

if [ "$SKIP_UPDATE" == "False" ] ; then
    source $KIRA_WORKSTATION/init.sh "True"
fi

${KIRA_SCRIPTS}/cdhelper-update.sh "v0.6.12"
CDHelper version

CDHelper text lineswap --insert="SILENT_MODE=$SILENT_MODE" --prefix="SILENT_MODE=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="DEBUG_MODE=$DEBUG_MODE" --prefix="DEBUG_MODE=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="NOTIFICATIONS=$NOTIFICATIONS" --prefix="NOTIFICATIONS=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="SMTP_LOGIN=$SMTP_LOGIN" --prefix="SMTP_LOGIN=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="SMTP_PASSWORD=$SMTP_PASSWORD" --prefix="SMTP_PASSWORD=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="SMTP_SECRET={\\\"host\\\":\\\"smtp.gmail.com\\\",\\\"port\\\":\\\"587\\\",\\\"ssl\\\":true,\\\"login\\\":\\\"$SMTP_LOGIN\\\",\\\"password\\\":\\\"$SMTP_PASSWORD\\\"}" --prefix="SMTP_SECRET=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE

CDHelper text lineswap --insert="SSH_KEY_PRIV_PATH=$SSH_KEY_PRIV_PATH" --prefix="SSH_KEY_PRIV_PATH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="KIRA_USER=$KIRA_USER" --prefix="KIRA_USER=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="USER_SHORTCUTS=/home/$KIRA_USER/.local/share/applications" --prefix="USER_SHORTCUTS=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="EMAIL_NOTIFY=$EMAIL_NOTIFY" --prefix="EMAIL_NOTIFY=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="INFRA_BRANCH=$INFRA_BRANCH" --prefix="INFRA_BRANCH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="SEKAI_BRANCH=$SEKAI_BRANCH" --prefix="SEKAI_BRANCH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="INFRA_REPO=$INFRA_REPO" --prefix="INFRA_REPO=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="SEKAI_REPO=$SEKAI_REPO" --prefix="SEKAI_REPO=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="SEKAI_REPO_SSH=$SEKAI_REPO_SSH" --prefix="SEKAI_REPO_SSH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="INFRA_REPO_SSH=$INFRA_REPO_SSH" --prefix="INFRA_REPO_SSH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE

source $KIRA_WORKSTATION/setup.sh "True"

echo "------------------------------------------------"
echo "|       FINISHED: KIRA INFRA INIT v0.0.1       |"
echo "------------------------------------------------"

