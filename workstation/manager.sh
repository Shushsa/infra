#!/bin/bash

exec 2>&1
set -e

# Local Update Shortcut:
# (rm -fv $KIRA_MANAGER/manager.sh) && nano $KIRA_MANAGER/manager.sh && chmod 777 $KIRA_MANAGER/manager.sh && touch /tmp/rs_manager

ETC_PROFILE="/etc/profile"
LOOP_FILE="/tmp/manager_loop"
VARS_FILE="/tmp/manager_vars"
RESTART_SIGNAL="/tmp/rs_manager"
source $ETC_PROFILE &> /dev/null
if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi

function checkContainerStatus() {
    i="$1" && name="$2" && output="$3"
    CONTAINER_ID=$(docker ps --no-trunc -aqf name=$name || echo "")

    echo "CONTAINER_ID_$i=$CONTAINER_ID" >> $output
    [ -z "$CONTAINER_ID" ] && echo "SUCCESS=False" >> $output && exit 0
    CONTAINER_STATUS=$(docker inspect $CONTAINER_ID 2>/dev/null | jq -r '.[0].State.Status' 2>/dev/null || echo "error")
        
    #Add block height info
    if [ "$CONTAINER_STATUS" == "running" ] ; then
        HEALTH=$(docker inspect $(docker ps --no-trunc -aqf name=$name ) 2>/dev/null | jq -r '.[0].State.Health.Status' 2>/dev/null || echo "")
        [ "$HEALTH" != "healthy" ] && [ "$HEALTH" != "null" ] && echo "SUCCESS=False" >> $output
        
        if [ ! -z "$HEALTH" ] && [ "$HEALTH" != "null" ] ; then
            CONTAINER_STATUS=$HEALTH
            HEIGHT=$(docker exec -i $name sekaicli status 2>/dev/null | jq -r '.sync_info.latest_block_height' 2>/dev/null | xargs || echo "")
            [ ! -z "$HEIGHT" ] && CONTAINER_STATUS="$CONTAINER_STATUS:$HEIGHT"
        fi
        echo "RUNNING=True" >> $output
    else
        [ -z "$CONTAINER_STATUS" ] && CONTAINER_STATUS="error"
        echo "SUCCESS=False" >> $output
    fi

    echo "CONTAINER_STATUS_$i=$CONTAINER_STATUS" >> $output
}

while : ; do
    START_TIME="$(date -u +%s)"
    [ -f $RESTART_SIGNAL ] && break
    
    SUCCESS="True"
    RUNNING="False" # at leat one running container

    rm -f $VARS_FILE && touch $VARS_FILE
    CONTAINERS=$(docker ps -a | awk '{if(NR>1) print $NF}' | tac)
    i=-1 ; for name in $CONTAINERS ; do i=$((i+1))
        checkContainerStatus "$i" "$name" "$VARS_FILE" &
    done

    CONTAINERS_COUNT=$((i+1))

    wait
    source $VARS_FILE
    clear
    
    echo -e "\e[33;1m------------------------------------------------"
    echo "|         KIRA NETWORK MANAGER v0.0.3          |"
    echo "|             $(date '+%d/%m/%Y %H:%M:%S')              |"
    [ "$SUCCESS" == "True" ] && echo -e "|\e[0m\e[32;1m     SUCCESS, INFRASTRUCTURE IS HEALTHY       \e[33;1m|"
    [ "$SUCCESS" != "True" ] && echo -e "|\e[0m\e[31;1m ISSUES DETECTED, INFRASTRUCTURE IS UNHEALTHY \e[33;1m|"
    echo "|----------------------------------------------| [status:height]"
    i=-1 ; for name in $CONTAINERS ; do i=$((i+1))
        CONTAINER_ID="CONTAINER_ID_$i" && [ -z "${!CONTAINER_ID}" ] && continue
        CONTAINER_STATUS="CONTAINER_STATUS_$i" && status="${!CONTAINER_STATUS}"
        LABEL="| [$i] | Inspect $name container                 "
        echo "${LABEL:0:46} : $status"
    done
    echo "|----------------------------------------------|"
    echo "| [A] | Mange INFRA Repo ($INFRA_BRANCH)"
    echo "| [B] | Mange SEKAI Repo ($SEKAI_BRANCH)"
    echo "|----------------------------------------------|"
    echo "| [I] | Re-INITALIZE Environment               |"
    [ "$CONTAINERS_COUNT" != "0" ] && \
    echo "| [S] | STOP All Containers                    |"
    [ "$CONTAINERS_COUNT" != "0" ] && [ "$RUNNING" == "False" ] && \
    echo "| [R] | Re-START All Containers                |"
    echo "| [H] | HARD-Reset Repos & Infrastructure      |"
    echo "| [D] | DELETE Repos & Infrastructure          |"
    echo "|----------------------------------------------|"
    echo "| [X] | Exit | [W] | Refresh Window            |"
    echo -e "------------------------------------------------\e[0m"
    
    echo "Input option then press [ENTER] or [SPACE]: " && rm -f $LOOP_FILE && touch $LOOP_FILE
    while : ; do
        [ -f $LOOP_FILE ] && OPTION=$(cat $LOOP_FILE)
        [ -f $RESTART_SIGNAL ] && break
        [ -z "$OPTION" ] && [ $(($(date -u +%s)-$START_TIME)) -ge 15 ] && break
        read -n 1 -t 5 KEY || continue
        [ ! -z "$KEY" ] && echo "${OPTION}${KEY}" > $LOOP_FILE
        [ -z "$KEY" ] && break
    done
    OPTION=$(cat $LOOP_FILE || echo "") && [ -z "$OPTION" ] && continue
    ACCEPT="" && while [ "${ACCEPT,,}" != "y" ] && [ "${ACCEPT,,}" != "n" ] ; do echo -e "\e[36;1mPress [Y]es to confirm option (${OPTION^^}) or [N]o to cancel: \e[0m\c" && read  -d'' -s -n1 ACCEPT ; done
    echo "" && [ "${ACCEPT,,}" == "n" ] && echo "WARINIG: Operation was cancelled" && continue

    BREAK="False"
    for ((i=1;i<=$VALIDATORS_COUNT;i++)); do
        if [ "$OPTION" == "$i" ] ; then
            gnome-terminal -- bash -c "$KIRA_MANAGER/container-manager.sh validator-$i ; read -d'' -s -n1 -p 'Press any key to exit...' && exit"
            BREAK="True"
            break
        fi 
    done

    [ "$BREAK" == "True" ] && continue
    
    if [ "$OPTION" == "0" ] ; then
        gnome-terminal -- bash -c "$KIRA_MANAGER/container-manager.sh 'registry' ; read -d'' -s -n1 -p 'Press any key to exit...' && exit"
        break
    elif [ "${OPTION,,}" == "a" ] ; then
        echo "INFO: Starting git manager..."
        gnome-terminal -- bash -c "$KIRA_MANAGER/git-manager.sh \"$INFRA_REPO_SSH\" \"$INFRA_REPO\" \"$INFRA_BRANCH\" \"$KIRA_INFRA\" \"INFRA_BRANCH\" ; read -d'' -s -n1 -p 'Press any key to exit...' && exit"
        break
    elif [ "${OPTION,,}" == "b" ] ; then
        echo "INFO: Starting git manager..."
        gnome-terminal -- bash -c "$KIRA_MANAGER/git-manager.sh \"$SEKAI_REPO_SSH\" \"$SEKAI_REPO\" \"$SEKAI_BRANCH\" \"$KIRA_SEKAI\" \"SEKAI_BRANCH\" ; read -d'' -s -n1 -p 'Press any key to exit...' && exit"
        break
    elif [ "${OPTION,,}" == "i" ] ; then
        echo "INFO: Wiping and re-initializing..."
        echo -e "\e[33;1mWARNING: You have to wait for new process to finish\e[0m"
        gnome-terminal --disable-factory -- bash -c "$KIRA_MANAGER/init.sh False ; read -d'' -s -n1 -p 'Press any key to exit...' && exit"
        break
    elif [ "${OPTION,,}" == "s" ] ; then
        echo "INFO: Stopping infrastructure..."
        echo -e "\e[33;1mWARNING: You have to wait for new process to finish\e[0m"
        gnome-terminal -- bash -c "$KIRA_MANAGER/stop.sh ; read -d'' -s -n1 -p 'Press any key to exit...' && exit"
        break
    elif [ "${OPTION,,}" == "r" ] ; then
        echo "INFO: Re-starting infrastructure..."
        echo -e "\e[33;1mWARNING: You have to wait for new process to finish\e[0m"
        gnome-terminal -- bash -c "$KIRA_MANAGER/restart.sh ; read -d'' -s -n1 -p 'Press any key to exit...' && exit"
        break
    elif [ "${OPTION,,}" == "h" ] ; then
        echo "INFO: Wiping and Restarting infra..."
        echo -e "\e[33;1mWARNING: You have to wait for new process to finish\e[0m"
        gnome-terminal -- bash -c "$KIRA_MANAGER/start.sh ; read -d'' -s -n1 -p 'Press any key to exit...' && exit"
        break
    elif [ "${OPTION,,}" == "d" ] ; then
        echo "INFO: Wiping and removing infra..."
        echo -e "\e[33;1mWARNING: You have to wait for new process to finish\e[0m"
        gnome-terminal --disable-factory -- bash -c "$KIRA_MANAGER/delete.sh ; read -d'' -s -n1 -p 'Press any key to exit...' && exit"
        break
    elif [ "${OPTION,,}" == "w" ] ; then
        echo "INFO: Please wait, refreshing user interface..." && break
    elif [ "${OPTION,,}" == "x" ] ; then
        exit 0
    fi
done

if [ -f $RESTART_SIGNAL ] ; then
   rm -f $RESTART_SIGNAL
else
    touch /tmp/rs_git_manager
    touch /tmp/rs_container_manager
fi

sleep 1
source $KIRA_MANAGER/manager.sh

