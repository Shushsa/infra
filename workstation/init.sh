
#!/bin/bash

exec 2>&1
set -e

# Local Update Shortcut:
# (rm -fv /tmp/init.sh) && nano /tmp/init.sh && chmod 777 /tmp/init.sh

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null
if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi

SKIP_UPDATE=$1
START_TIME=$2
DEBUG_MODE=$3

[ -z "$START_TIME" ] && START_TIME="$(date -u +%s)"
[ -z "$SKIP_UPDATE" ] && SKIP_UPDATE="False"
[ -z "$DEBUG_MODE" ] && DEBUG_MODE="False"
if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi

if [ "$SKIP_UPDATE" == "False" ] ; 
    echo -e "\e[36;1mPress [Y]es/[N]o is you want to run in debug mode, [ENTER] if '$DEBUG_MODE': \e[0m\c" && read  -d'' -s -n1 NEW_DEBUG_MODE
    if [ "${NEW_DEBUG_MODE,,}" == "y" ] ; then
        DEBUG_MODE="True"
    elif [ "${NEW_DEBUG_MODE,,}" == "n" ]  ; then
        DEBUG_MODE="False"
    fi
fi

if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi

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

if [ "$SKIP_UPDATE" == "False" ] ; then
    source /kira/infra/workstation/setup/essentials.sh $DEBUG_MODE
    source $ETC_PROFILE &> /dev/null

    echo -e "\e[36;1mType INFRA reposiotry branch, [ENTER] if '$INFRA_BRANCH': \e[0m\c" && read NEW_INFRA_BRANCH
    [ ! -z "$NEW_INFRA_BRANCH" ] && INFRA_BRANCH=$NEW_INFRA_BRANCH

    echo "INFO: Updating Infra Repository..."
    rm -rfv $KIRA_INFRA
    mkdir -p $KIRA_INFRA
    git clone --branch $INFRA_BRANCH $INFRA_REPO $KIRA_INFRA
    cd $KIRA_INFRA
    git describe --all --always
    chmod -R 777 $KIRA_INFRA

    # update old processes
    rm -r -f $KIRA_MANAGER
    cp -r $KIRA_WORKSTATION $KIRA_MANAGER
    chmod -R 777 $KIRA_MANAGER

    echo "INFO: Base Tools Setup..."
    ${KIRA_SCRIPTS}/cdhelper-update.sh "v0.6.12"
    CDHelper version

    cd /kira
    source $KIRA_WORKSTATION/init.sh "True" "$START_TIME"
    exit 0
else
    chmod 700 $SSH_PATH
    if [ ! -f $SSH_KEY_PRIV_PATH ] ; then
        ssh-keygen -q -t rsa -N '' -f $SSH_KEY_PRIV_PATH 2>/dev/null <<< y >/dev/null
        chmod 600 $SSH_KEY_PRIV_PATH
    fi

    echo -e "\e[36;1mType SEKAI reposiotry branch, [ENTER] if '$SEKAI_BRANCH': \e[0m\c" && read NEW_SEKAI_BRANCH
    [ ! -z "$NEW_SEKAI_BRANCH" ] && SEKAI_BRANCH=$NEW_SEKAI_BRANCH
    
    echo -e "\e[36;1mPress [Y]es/[N]o to receive notifications, [ENTER] if '$NOTIFICATIONS': \e[0m\c" && read  -d'' -s -n1 NEW_NOTIFICATIONS
    if [ "${NEW_NOTIFICATIONS,,}" == "y" ] ; then
        NOTIFICATIONS="True"
    elif [ "${NEW_NOTIFICATIONS,,}" == "n" ] ; then
        NOTIFICATIONS="False"
    fi
    
    if [ "$NOTIFICATIONS" == "True" ] ; then
        echo -e "\e[36;1mType desired notification email, [ENTER] if '$EMAIL_NOTIFY': \e[0m\c" && read NEW_NOTIFY_EMAIL
        [ ! -z "$NEW_NOTIFY_EMAIL" ] && EMAIL_NOTIFY=$NEW_NOTIFY_EMAIL
        
        echo -e "\e[36;1mType Gmail SMTP login, [ENTER] if '$SMTP_LOGIN': \e[0m\c" && read NEW_SMTP_LOGIN
        [ ! -z "$NEW_SMTP_LOGIN" ] && SMTP_LOGIN=$NEW_SMTP_LOGIN
        
        echo -e "\e[36;1mType Gmail SMTP password, [ENTER] if '$SMTP_PASSWORD': \e[0m\c" && read NEW_SMTP_PASSWORD
        [ ! -z "$NEW_SMTP_PASSWORD" ] && SMTP_PASSWORD=$NEW_SMTP_PASSWORD
    fi
    
    ssh-keygen -y -f $SSH_KEY_PRIV_PATH > $SSH_KEY_PUB_PATH
    chmod 644 $SSH_KEY_PUB_PATH
    SSH_KEY_PUB=$(cat $SSH_KEY_PUB_PATH)

    echo "INFO: Your current public SSH Key:"
    echo -e "\e[33;1m$SSH_KEY_PUB\e[0m"
    
    echo -e "\e[36;1mInput your PRIVATE git SSH key, [ENTER] if above PUB key: \e[0m\c" && read NEW_SSH_KEY
    if [ ! -z "$NEW_SSH_KEY" ] ; then
        echo $NEW_SSH_KEY > $SSH_KEY_PRIV_PATH
        ssh-keygen -y -f $SSH_KEY_PRIV_PATH > $SSH_KEY_PUB_PATH
        chmod 600 $SSH_KEY_PRIV_PATH
        chmod 644 $SSH_KEY_PUB_PATH
        SSH_KEY_PUB=$(cat $SSH_KEY_PUB_PATH)
    
        echo "INFO: Your new public SSH Key:"
        echo -e "\e[32;1m$SSH_KEY_PUB\e[0m"
    fi

    echo -e "\e[36;1mPress [Y]es/[N]o to display your private key: \e[0m\c" && read  -d'' -s -n1 SHOW_PRIV_KEY
    if [ "${NEW_NOTIFICATIONS,,}" == "y" ] ; then
        echo "INFO: Your private SSH Key: (select, copy and save it for future recovery)"
        echo -e "\e[32;1m$(cat $SSH_KEY_PRIV_PATH)\e[0m"
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
    echo "| PUBLIC GIT SSH KEY: $(echo $SSH_KEY_PUB | head -c 24)...$(echo $SSH_KEY_PUB | tail -c 24)"
    echo -e "------------------------------------------------\e[0m"
    
    echo -e "\e[36;1mPress [ENTER] to confirm or any other key to exit: \e[0m\c" && read  -d'' -s -n1 ACCEPT
    [ ! -z "$ACCEPT" ] && exit 1
fi

CDHelper text lineswap --insert="NOTIFICATIONS=$NOTIFICATIONS" --prefix="NOTIFICATIONS=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="SMTP_LOGIN=$SMTP_LOGIN" --prefix="SMTP_LOGIN=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="SMTP_PASSWORD=$SMTP_PASSWORD" --prefix="SMTP_PASSWORD=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="SMTP_SECRET={\\\"host\\\":\\\"smtp.gmail.com\\\",\\\"port\\\":\\\"587\\\",\\\"ssl\\\":true,\\\"login\\\":\\\"$SMTP_LOGIN\\\",\\\"password\\\":\\\"$SMTP_PASSWORD\\\"}" --prefix="SMTP_SECRET=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE

CDHelper text lineswap --insert="KIRA_USER=$KIRA_USER" --prefix="KIRA_USER=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="USER_SHORTCUTS=/home/$KIRA_USER/.local/share/applications" --prefix="USER_SHORTCUTS=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="EMAIL_NOTIFY=$EMAIL_NOTIFY" --prefix="EMAIL_NOTIFY=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="INFRA_BRANCH=$INFRA_BRANCH" --prefix="INFRA_BRANCH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="SEKAI_BRANCH=$SEKAI_BRANCH" --prefix="SEKAI_BRANCH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="INFRA_REPO=$INFRA_REPO" --prefix="INFRA_REPO=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="SEKAI_REPO=$SEKAI_REPO" --prefix="SEKAI_REPO=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="SEKAI_REPO_SSH=$SEKAI_REPO_SSH" --prefix="SEKAI_REPO_SSH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="INFRA_REPO_SSH=$INFRA_REPO_SSH" --prefix="INFRA_REPO_SSH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
chmod 777 $ETC_PROFILE

cd /kira
source $KIRA_WORKSTATION/start.sh "True"

echo "------------------------------------------------"
echo "| FINISHED: KIRA INFRA INIT v0.0.2             |"
echo "|  ELAPSED: $(($(date -u +%s)-$START_TIME)) seconds"
echo "------------------------------------------------"

