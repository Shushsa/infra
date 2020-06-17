#!/bin/bash

exec 2>&1
set -e

# Local Update Shortcut:
# (rm -fv $KIRA_WORKSTATION/setup.sh) && nano $KIRA_WORKSTATION/setup.sh && chmod 777 $KIRA_WORKSTATION/setup.sh

SKIP_UPDATE=$1
START_TIME=$2

[ -z "$START_TIME" ] && START_TIME="$(date -u +%s)"
[ -z "$SKIP_UPDATE" ] && SKIP_UPDATE="False"

BASHRC=~/.bashrc
ETC_PROFILE="/etc/profile"

source $ETC_PROFILE &> /dev/null

[ "$DEBUG_MODE" == "True" ] && set -x
[ "$DEBUG_MODE" == "False" ] && set +x

echo "------------------------------------------------"
echo "|       STARTED: KIRA INFRA SETUP v0.0.2       |"
echo "|----------------------------------------------|"
echo "|       INFRA BRANCH: $INFRA_BRANCH"
echo "|       SEKAI BRANCH: $SEKAI_BRANCH"
echo "|         INFRA REPO: $INFRA_REPO"
echo "|         SEKAI REPO: $SEKAI_REPO"
echo "| NOTIFICATION EMAIL: $EMAIL_NOTIFY"
echo "|        SKIP UPDATE: $SKIP_UPDATE"
echo "|          KIRA USER: $KIRA_USER"
echo "|_______________________________________________"

[ -z "$INFRA_BRANCH" ] && echo "ERROR: INFRA_BRANCH env was not defined" && exit 1
[ -z "$SEKAI_BRANCH" ] && echo "ERROR: SEKAI_BRANCH env was not defined" && exit 1
[ -z "$INFRA_REPO" ] && echo "ERROR: INFRA_REPO env was not defined" && exit 1
[ -z "$SEKAI_REPO" ] && echo "ERROR: SEKAI_REPO env was not defined" && exit 1
[ -z "$EMAIL_NOTIFY" ] && echo "ERROR: EMAIL_NOTIFY env was not defined" && exit 1
[ -z "$KIRA_USER" ] && echo "ERROR: KIRA_USER env was not defined" && exit 1

$KIRA_SCRIPTS/progress-touch.sh "+1" #1

cd /kira
if [ "$SKIP_UPDATE" == "False" ] ; then
    echo "INFO: Updating Infra..."
    $KIRA_SCRIPTS/git-pull.sh "$INFRA_REPO" "$INFRA_BRANCH" "$KIRA_INFRA" 777 && $KIRA_SCRIPTS/progress-touch.sh "+1" #2
    $KIRA_SCRIPTS/git-pull.sh "$SEKAI_REPO" "$SEKAI_BRANCH" "$KIRA_SEKAI" && $KIRA_SCRIPTS/progress-touch.sh "+1" #3

    # we must ensure that recovery files can't be destroyed in the update process and cause a deadlock
    rm -r -f $KIRA_MANAGER
    cp -r $KIRA_WORKSTATION $KIRA_MANAGER
    chmod -R 777 $KIRA_MANAGER

    source $KIRA_WORKSTATION/setup.sh "True" "$START_TIME"
    exit 0
elif [ "$SKIP_UPDATE" == "True" ] ; then
    echo "INFO: Skipping Infra Update..."
else
    echo "ERROR: SKIP_UPDATE propoerty is invalid or undefined"
    exit 1
fi

$KIRA_SCRIPTS/cdhelper-update.sh "v0.6.12" && $KIRA_SCRIPTS/progress-touch.sh "+1" #4
$KIRA_SCRIPTS/awshelper-update.sh "v0.12.4" && $KIRA_SCRIPTS/progress-touch.sh "+1" #5

source $KIRA_WORKSTATION/setup/certs.sh #6
source $KIRA_WORKSTATION/setup/envs.sh #7
source $KIRA_WORKSTATION/setup/hosts.sh #8
source $KIRA_WORKSTATION/setup/system.sh #9
source $KIRA_WORKSTATION/setup/tools.sh #10
source $KIRA_WORKSTATION/setup/npm.sh #11
source $KIRA_WORKSTATION/setup/rust.sh #12
source $KIRA_WORKSTATION/setup/dotnet.sh #13
source $KIRA_WORKSTATION/setup/systemctl2.sh #14
source $KIRA_WORKSTATION/setup/docker.sh #15
source $KIRA_WORKSTATION/setup/golang.sh #16
source $KIRA_WORKSTATION/setup/nginx.sh #17
source $KIRA_WORKSTATION/setup/chrome.sh #18
source $KIRA_WORKSTATION/setup/vscode.sh #19
source $KIRA_WORKSTATION/setup/registry.sh #20
source $KIRA_WORKSTATION/setup/shortcuts.sh #21

touch /tmp/rs_manager
touch /tmp/rs_git_manager
touch /tmp/rs_container_manager

echo "------------------------------------------------"
echo "| FINISHED: KIRA INFRA SETUP v0.0.2            |"
echo "|  ELAPSED: $(($(date -u +%s)-$START_TIME)) seconds"
echo "------------------------------------------------"
