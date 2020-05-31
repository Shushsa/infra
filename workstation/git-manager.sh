#!/bin/bash

exec 2>&1
set -e

REPO_SSH=$1
REPO_HTTPS=$2
BRANCH=$3
DIRECTORY=$4

[ -z "$REPO" ] && REPO=$REPO_SSH
[ -z "$REPO" ] && REPO=$REPO_HTTPS

ETC_PROFILE="/etc/profile"

while : ; do
    source $ETC_PROFILE &> /dev/null
    if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi
    
    clear
    
    echo -e "\e[32;1m------------------------------------------------"
    echo "|           KIRA GIT MANAGER v0.0.1            |"
    echo "|             $(date '+%d/%m/%Y %H:%M:%S')              |"
    echo "|----------------------------------------------|"
    echo "| Repository: $REPO"
    echo "|     Branch: $BRANCH"
    echo "|   Location: $DIRECTORY"
    echo "|----------------------------------------------|"
    echo "| [V] | VIEW Repo in Code Editor               |"
    echo "| [C] | COMMIT and Push Changes                |"
    echo "| [R] | Delete Repo and RESTORE from Remote    |"
    echo "|----------------------------------------------|"
    echo "| [X] | Exit                                   |"
    echo -e "------------------------------------------------\e[0m"
    
    read  -d'' -s -n1 -t 3 -p "INFO: Press [KEY] to select option: " OPTION || OPTION=""
    [ ! -z "$OPTION" ] && echo "" && read -d'' -s -n1 -p "Press [ENTER] to confirm [${OPTION^^}] option or any other key to try again: " ACCEPT
    [ ! -z "$ACCEPT" ] && break
    cd /kira
    
    if [ "${OPTION,,}" == "v" ] ; then
        echo "INFO: Starting code editor..."
        code --user-data-dir /usr/code $DIRECTORY
        sleep 3
        break
    elif [ "${OPTION,,}" == "c" ] ; then
        echo -e "\e[36;1mType desired commit message: \e[0m\c" && read COMMIT
        if [ -z "$COMMIT" ] ; then
            echo "WARINIG: Commit message was not set"
            FORCE="" && while [ "${FORCE,,}" != "y" ] && [ "${FORCE,,}" != "n" ] ; do echo -e "\n\e[36;1mPress [Y]es to commit empty message or [N]o to cancel: \e[0m\c" && read  -d'' -s -n1 FORCE ; done
            if [ "${FORCE,,}" == "y" ] ; then
                COMMIT="Forced commit or minor changes"
            else
                echo "WARINIG: Commit was cancelled"
                sleep 3
                break
            fi
        fi
        cd $DIRECTORY
        echo "INFO: Commiting changes..."
        sleep 1
        FAILED="False"
        git commit -am "[$(date '+%d/%m/%Y %H:%M:%S')] $COMMIT" || FAILED="True"
    
        if [ "$FAILED" == "True" ] ; then
            echo "ERROR: Commit failed"
            sleep 3
            break
        fi
        
        echo "INFO: Pushing changes..."
        git remote set-url origin $REPO_SSH || FAILED="True"
        [ "$FAILED" == "False" ] && ssh-agent sh -c "ssh-add $SSH_KEY_PRIV_PATH ; git push origin $BRANCH" ||  FAILED="True"

        if [ "$FAILED" == "True" ] ; then
            echo "ERROR: Push failed"
            sleep 3
            break
        fi

        echo "SUCCESS: Push suceeded"
        sleep 3
    elif [ "${OPTION,,}" == "r" ] ; then
        $KIRA_SCRIPTS/git-pull.sh "$REPO_SSH" "$BRANCH" "$DIRECTORY"
        chmod -R 777 $DIRECTORY
        break
    elif [ "${OPTION,,}" == "x" ] ; then
        exit
    fi
done

sleep 1
source $KIRA_MANAGER/git-manager.sh "$REPO_SSH" "$REPO_HTTPS" "$BRANCH" "$DIRECTORY"

# TODO: Check if below commands can be fully ommited 
# git config --global user.name github-username
# git config --global user.email github@email
# ssh-agent -s 
# eval `ssh-agent -s`
# ssh-add $SSH_KEY_PRIV_PATH