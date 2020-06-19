
#!/bin/bash

exec 2>&1
set -e

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

if [ "$SKIP_UPDATE" == "False" ] ; then
    echo -e "\e[36;1mPress [Y]es/[N]o is you want to run in debug mode, [ENTER] if '$DEBUG_MODE': \e[0m\c" && read  -d'' -s -n1 NEW_DEBUG_MODE
    if [ "${NEW_DEBUG_MODE,,}" == "y" ] ; then
        DEBUG_MODE="True"
    elif [ "${NEW_DEBUG_MODE,,}" == "n" ]  ; then
        DEBUG_MODE="False"
    fi
fi

if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi

MAX_VALIDATORS=254
[ -z "$INFRA_BRANCH" ] && INFRA_BRANCH="master"
[ -z "$SEKAI_BRANCH" ] && SEKAI_BRANCH="master"
[ -z "$EMAIL_NOTIFY" ] && EMAIL_NOTIFY="noreply.example.email@gmail.com"
[ -z "$SMTP_LOGIN" ] && SMTP_LOGIN="noreply.example.email@gmail.com"
[ -z "$SMTP_PASSWORD" ] && SMTP_PASSWORD="wpzpjrfsfznyeohs"
[ -z "$INFRA_REPO" ] && INFRA_REPO="https://github.com/KiraCore/infra"
[ -z "$SEKAI_REPO" ] && SEKAI_REPO="https://github.com/KiraCore/sekai"
[ -z "$SEKAI_REPO_SSH" ] && SEKAI_REPO_SSH="git@github.com:KiraCore/sekai.git"
[ -z "$INFRA_REPO_SSH" ] && INFRA_REPO_SSH="git@github.com:KiraCore/infra.git"
[ -z "$NOTIFICATIONS" ] && NOTIFICATIONS="False"
[ -z "$VALIDATORS_COUNT" ] && VALIDATORS_COUNT=2
[ ! -z "$SUDO_USER" ] && KIRA_USER=$SUDO_USER
[ -z "$KIRA_USER" ] && KIRA_USER=$USER
[ "$KIRA_USER" == "root" ] && KIRA_USER=$(logname)
[ "$KIRA_USER" == "root" ] && echo "You must login as non root user to your machine"

if [ "$SKIP_UPDATE" == "False" ] ; then
    #########################################
    # START Installing Essentials
    #########################################
    SSH_PATH=/home/root/.ssh
    KIRA_INFRA=/kira/infra
    KIRA_SEKAI=/kira/sekai
    KIRA_SETUP=/kira/setup
    KIRA_MANAGER="/kira/manager"
    KIRA_PROGRESS="/kira/progress"
    KIRA_DUMP="/home/$KIRA_USER/Desktop/DUMP"
    KIRA_SCRIPTS="${KIRA_INFRA}/common/scripts"
    KIRA_WORKSTATION="${KIRA_INFRA}/workstation"
    
    mkdir -p $SSH_PATH
    mkdir -p $KIRA_INFRA
    mkdir -p $KIRA_SEKAI
    mkdir -p $KIRA_SETUP
    mkdir -p $KIRA_MANAGER
    mkdir -p $KIRA_PROGRESS
    rm -rfv $KIRA_DUMP
    mkdir -p "$KIRA_DUMP/infra"

    KIRA_SETUP_ESSSENTIALS="$KIRA_SETUP/essentials-v0.0.2" 
    if [ ! -f "$KIRA_SETUP_ESSSENTIALS" ] ; then
        echo "INFO: Installing Essential Packages and Variables..."
        apt-get update -y > /dev/null
        apt-get install -y --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages \
            software-properties-common apt-transport-https ca-certificates gnupg curl wget git unzip openssh-client openssh-server sshfs > /dev/null

        ln -s /usr/bin/git /bin/git || echo "WARNING: Git symlink already exists"
        git config --add --global user.name dev || echo "WARNING: Failed to set global user name"
        git config --add --global user.email dev@local || echo "WARNING: Failed to set global user email"
        git config --add --global core.autocrlf input || echo "WARNING: Failed to set global autocrlf"
        git config --unset --global core.filemode || echo "WARNING: Failed to unset global filemode"
        git config --add --global core.filemode false || echo "WARNING: Failed to set global filemode"
    
        echo "INFO: Base Tools Setup..."
        cd /tmp
        INSTALL_DIR="/usr/local/bin"
        rm -f -v ./CDHelper-linux-x64.zip
        wget https://github.com/asmodat/CDHelper/releases/download/v0.6.12/CDHelper-linux-x64.zip
        rm -rfv $INSTALL_DIR
        unzip CDHelper-linux-x64.zip -d $INSTALL_DIR
        chmod -R -v 777 $INSTALL_DIR
        
        ln -s $INSTALL_DIR/CDHelper /bin/CDHelper || echo "CDHelper symlink already exists"
        
        CDHelper version

        echo "INFO: Setting up Essential Variables and Configs..."
        SSHD_CONFIG="/etc/ssh/sshd_config"
        CDHelper text lineswap --insert="PermitRootLogin yes " --prefix="PermitRootLogin" --path=$SSHD_CONFIG --append-if-found-not=True --silent=$SILENT_MODE
        CDHelper text lineswap --insert="PasswordAuthentication yes " --prefix="PasswordAuthentication" --path=$SSHD_CONFIG --append-if-found-not=True --silent=$SILENT_MODE
        service ssh restart || echo "WARNING: Failed to restart ssh service"

        CDHelper text lineswap --insert="KIRA_MANAGER=$KIRA_MANAGER" --prefix="KIRA_MANAGER=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
        CDHelper text lineswap --insert="KIRA_SETUP=$KIRA_SETUP" --prefix="KIRA_SETUP=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
        CDHelper text lineswap --insert="KIRA_INFRA=$KIRA_INFRA" --prefix="KIRA_INFRA=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
        CDHelper text lineswap --insert="KIRA_SEKAI=$KIRA_SEKAI" --prefix="KIRA_SEKAI=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
        CDHelper text lineswap --insert="KIRA_SCRIPTS=$KIRA_SCRIPTS" --prefix="KIRA_SCRIPTS=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
        CDHelper text lineswap --insert="KIRA_WORKSTATION=$KIRA_WORKSTATION" --prefix="KIRA_WORKSTATION=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$
    
        SSH_KEY_PUB_PATH=$SSH_PATH/id_rsa.pub
        SSH_KEY_PRIV_PATH=$SSH_PATH/id_rsa
        CDHelper text lineswap --insert="SSH_PATH=$SSH_PATH" --prefix="SSH_PATH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
        CDHelper text lineswap --insert="SSH_KEY_PUB_PATH=$SSH_KEY_PUB_PATH" --prefix="SSH_KEY_PUB_PATH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
        CDHelper text lineswap --insert="SSH_KEY_PRIV_PATH=$SSH_KEY_PRIV_PATH" --prefix="SSH_KEY_PRIV_PATH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    
        touch $KIRA_SETUP_ESSSENTIALS
    else
        echo "INFO: Essentials were already installed: $(git --version), Curl, Wget..."
    fi
    
    CDHelper text lineswap --insert="SILENT_MODE=$SILENT_MODE" --prefix="SILENT_MODE=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    CDHelper text lineswap --insert="DEBUG_MODE=$DEBUG_MODE" --prefix="DEBUG_MODE=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
    #########################################
    # END Installing Essentials
    #########################################

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
    [ "${NEW_NOTIFICATIONS,,}" == "y" ] && NOTIFICATIONS="True"
    [ "${NEW_NOTIFICATIONS,,}" == "n" ] && NOTIFICATIONS="False"
    
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

    while : ; do
        echo "INFO: Your current public SSH Key:"
        echo -e "\e[33;1m$SSH_KEY_PUB\e[0m"
        
        echo -e "\e[36;1mPress [Y] and paste your PRIVATE git SSH key or press [ENTER] to skip: \e[0m\c" && read -n1 NEW_SSH_KEY
        if [ "${NEW_SSH_KEY,,}" == "y" ] ; then
            echo -e "\nINFO: Press [Ctrl+D] to save input, or use [Ctrl+C] to exit without changes\n"
            set +e
            NEW_SSH_KEY=$(</dev/stdin)
            set -e
        else
            break
        fi

        if [ ! -z "$NEW_SSH_KEY" ] ; then
            rm -rfv $SSH_KEY_PRIV_PATH
            rm -rfv $SSH_KEY_PUB_PATH
            echo -e "$NEW_SSH_KEY" > $SSH_KEY_PRIV_PATH
            chmod 600 $SSH_KEY_PRIV_PATH
            ssh-keygen -y -f $SSH_KEY_PRIV_PATH > $SSH_KEY_PUB_PATH
            chmod 644 $SSH_KEY_PUB_PATH
            SSH_KEY_PUB=$(cat $SSH_KEY_PUB_PATH)
        
            echo "INFO: Your new public SSH Key:"
            echo -e "\e[32;1m$SSH_KEY_PUB\e[0m"
        else
            echo "ERROR: Private key was not submitted"
        fi

        echo -e "\e[36;1mPress [Y]es to confirm or [N]o to try again: \e[0m\c " && read  -d'' -s -n1 OPTION
        [ "${OPTION,,}" == "y" ] && break
        [ "${OPTION,,}" == "n" ] && continue
    done

    echo "INFO: Make sure you copied and saved your private key for recovery purpouses"
    echo -e "\e[36;1mPress [Y]es/[N]o to display your private key: \e[0m\c" && read  -d'' -s -n1 SHOW_PRIV_KEY
    if [ "${SHOW_PRIV_KEY,,}" == "y" ] ; then
        echo "INFO: Your private SSH Key: (select, copy and save it for future recovery)"
        echo -e "\e[32;1m$(cat $SSH_KEY_PRIV_PATH)\e[0m"
    fi

    if [ ! -z "$NEW_SSH_KEY" ] ; then 
        echo -e "\e[36;1mPress [Y]es/[N]o to display your public key: \e[0m\c" && read  -d'' -s -n1 SHOW_PUB_KEY
        if [ "${SHOW_PUB_KEY,,}" == "y" ] ; then
            echo "INFO: Your public SSH Key:"
            echo -e "\e[32;1m$(cat $SSH_KEY_PUB_PATH)\e[0m"
        fi
    fi

    echo -e "\e[36;1mInput number of validators to deploy (min 1, max $MAX_VALIDATORS), [ENTER] if '$VALIDATORS_COUNT': \e[0m\c" && read NEW_VALIDATORS_COUNT
    [ ! -z "$NEW_VALIDATORS_COUNT" ] && [ ! -z "${NEW_VALIDATORS_COUNT##*[!0-9]*}" ] && [ $NEW_VALIDATORS_COUNT -ge 1 ] && [ $NEW_VALIDATORS_COUNT -le $MAX_VALIDATORS ] && VALIDATORS_COUNT=$NEW_VALIDATORS_COUNT

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
    echo "|   VALIDATORS COUNT: $VALIDATORS_COUNT"
    echo "| PUBLIC GIT SSH KEY: $(echo $SSH_KEY_PUB | head -c 24)...$(echo $SSH_KEY_PUB | tail -c 24)"
    echo -e "------------------------------------------------\e[0m"
    
    echo -e "\e[36;1mPress [ENTER] to confirm or any other key to exit: \e[0m\c" && read  -d'' -s -n1 ACCEPT
    [ ! -z "$ACCEPT" ] && exit 1
fi

CDHelper text lineswap --insert="NOTIFICATIONS=$NOTIFICATIONS" --prefix="NOTIFICATIONS=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="SMTP_LOGIN=$SMTP_LOGIN" --prefix="SMTP_LOGIN=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="SMTP_PASSWORD=$SMTP_PASSWORD" --prefix="SMTP_PASSWORD=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="SMTP_SECRET={\\\"host\\\":\\\"smtp.gmail.com\\\",\\\"port\\\":\\\"587\\\",\\\"ssl\\\":true,\\\"login\\\":\\\"$SMTP_LOGIN\\\",\\\"password\\\":\\\"$SMTP_PASSWORD\\\"}" --prefix="SMTP_SECRET=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE

CDHelper text lineswap --insert="KIRA_DUMP=$KIRA_DUMP" --prefix="KIRA_DUMP=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="KIRA_PROGRESS=$KIRA_PROGRESS" --prefix="KIRA_PROGRESS=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="KIRA_USER=$KIRA_USER" --prefix="KIRA_USER=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="USER_SHORTCUTS=/home/$KIRA_USER/.local/share/applications" --prefix="USER_SHORTCUTS=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="EMAIL_NOTIFY=$EMAIL_NOTIFY" --prefix="EMAIL_NOTIFY=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="INFRA_BRANCH=$INFRA_BRANCH" --prefix="INFRA_BRANCH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="SEKAI_BRANCH=$SEKAI_BRANCH" --prefix="SEKAI_BRANCH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="INFRA_REPO=$INFRA_REPO" --prefix="INFRA_REPO=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="SEKAI_REPO=$SEKAI_REPO" --prefix="SEKAI_REPO=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="SEKAI_REPO_SSH=$SEKAI_REPO_SSH" --prefix="SEKAI_REPO_SSH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="INFRA_REPO_SSH=$INFRA_REPO_SSH" --prefix="INFRA_REPO_SSH=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="VALIDATORS_COUNT=$VALIDATORS_COUNT" --prefix="VALIDATORS_COUNT=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE
CDHelper text lineswap --insert="MAX_VALIDATORS=$MAX_VALIDATORS" --prefix="MAX_VALIDATORS=" --path=$ETC_PROFILE --append-if-found-not=True --silent=$SILENT_MODE

chmod 777 $ETC_PROFILE

cd /kira
$KIRA_SCRIPTS/progress-touch.sh "*0" 
$KIRA_WORKSTATION/start.sh "False" &>> "$KIRA_DUMP/infra/start.log" &
PID=$! && source $KIRA_SCRIPTS/progress-touch.sh "+0" "$((42+(2*$VALIDATORS_COUNT)))" 48 $PID
FAILURE="False" && wait $PID || FAILURE="True"
[ "$FAILURE" == "True" ] && echo "ERROR: Start script failed, logs are available in the '$KIRA_DUMP' directory" && exit 1

echo "------------------------------------------------"
echo "| FINISHED: KIRA INFRA INIT v0.0.2             |"
echo "|  ELAPSED: $(($(date -u +%s)-$START_TIME)) seconds"
echo "------------------------------------------------"

