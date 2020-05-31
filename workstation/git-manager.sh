#!/bin/bash

exec 2>&1
set -e

REPO_SSH=$1
REPO_HTTPS=$2
BRANCH=$3
DIRECTORY=$4
BRANCH_ENVAR=$5

[ -z "$REPO" ] && REPO=$REPO_SSH
[ -z "$REPO" ] && REPO=$REPO_HTTPS
[ -z "$BRANCH_ENVAR" ] && echo "Git manager failure, BRANCH_ENVAR property was not defined" && exit 1

ETC_PROFILE="/etc/profile"

while : ; do
    source $ETC_PROFILE &> /dev/null
    if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi
    mkdir -p $DIRECTORY
    cd $DIRECTORY
    
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
    echo "| [C] | COMMIT New Changes                     |"
    echo "| [P] | PUSH New Changes                       |"
    echo "| [R] | Delete Repo and RESTORE from Remote    |"
    echo "| [B] | Change to Diffrent Remote BRANCH       |"
    echo "| [N] | Create NEW Branch from Current Remote  |"
    echo "|----------------------------------------------|"
    echo "| [X] | Exit | [W] | Refresh Window            |"
    echo -e "------------------------------------------------\e[0m"
    
    read  -d'' -s -n1 -t 5 -p "INFO: Press [KEY] to select option: " OPTION || OPTION=""
    [ ! -z "$OPTION" ] && echo "" && read -d'' -s -n1 -p "Press [ENTER] to confirm [${OPTION^^}] option or any other key to try again: " ACCEPT
    [ ! -z "$ACCEPT" ] && break
    
    if [ "${OPTION,,}" == "v" ] ; then
        echo "INFO: Starting code editor..."
        code --user-data-dir /usr/code $DIRECTORY
        break
    elif [ "${OPTION,,}" == "c" ] ; then
        echo -e "\e[36;1mType desired commit message: \e[0m\c" && read COMMIT
        if [ -z "$COMMIT" ] ; then
            echo "WARINIG: Commit message was not set"
            FORCE="" && while [ "${FORCE,,}" != "y" ] && [ "${FORCE,,}" != "n" ] ; do echo -e "\n\e[36;1mPress [Y]es to commit empty message or [N]o to cancel: \e[0m\c" && read  -d'' -s -n1 FORCE ; done
            [ "${FORCE,,}" == "y" ] && COMMIT="Forced commit or minor changes"
            [ "${FORCE,,}" == "n" ] && "WARINIG: Commit was cancelled" && break
        fi
        echo "INFO: Commiting changes..."
        sleep 1
        FAILED="False"
        git commit -am "[$(date '+%d/%m/%Y %H:%M:%S')] $COMMIT" || FAILED="True"
        [ "$FAILED" == "True" ] && echo "ERROR: Commit failed" && break
        
        echo "SUCCESS: Commit suceeded" && break
    elif [ "${OPTION,,}" == "p" ] ; then
        echo "INFO: Pushing changes..."
        git remote set-url origin $REPO_SSH || FAILED="True"
        [ "$FAILED" == "False" ] && ssh-agent sh -c "ssh-add $SSH_KEY_PRIV_PATH ; git push origin $BRANCH" || FAILED="True"
        [ "$FAILED" == "True" ] && echo "ERROR: Push failed" && break
        
        echo "SUCCESS: Push suceeded" && break
    elif [ "${OPTION,,}" == "r" ] ; then
        $KIRA_SCRIPTS/git-pull.sh "$REPO_SSH" "$BRANCH" "$DIRECTORY" || FAILED="True"
        [ "$FAILED" == "True" ] && echo "ERROR: Pull failed" && break
      
        echo "SUCCESS: Pull suceeded" && break
    elif [ "${OPTION,,}" == "b" ] ; then
        echo "INFO: Listing available branches..."
        git branch -r || echo "ERROR: Failed to list remote branches"
        echo -e "\e[36;1mProvide name of existing remote branch to checkout: \e[0m\c" && read NEW_BRANCH
        [ -z "$NEW_BRANCH" ] && echo "ERROR: Branch was not defined" && break
        [ "$NEW_BRANCH" == "$BRANCH" ] && echo "ERROR: Can't switch to branch with the same name" && break

        $KIRA_SCRIPTS/git-pull.sh "$REPO_SSH" "$NEW_BRANCH" "$DIRECTORY" || FAILED="True"
        [ "$FAILED" == "True" ] && echo "ERROR: Changing branch failed" && break

        BRANCH=$NEW_BRANCH
        CDHelper text lineswap --insert="$BRANCH_ENVAR=$BRANCH" --prefix="$BRANCH_ENVAR=" --path=$ETC_PROFILE --silent=$SILENT_MODE
        
        echo "SUCCESS: Changing branch suceeded"
    elif [ "${OPTION,,}" == "n" ] ; then
        echo "INFO: Listing available branches..."
        git branch -r || echo "ERROR: Failed to list remote branches"
        echo -e "\e[36;1mProvide name of new branch to create: \e[0m\c" && read NEW_BRANCH
        git remote set-url origin $REPO_SSH || FAILED="True"
        [ -z "$NEW_BRANCH" ] && echo "ERROR: Branch was not defined" && break
        [ "$NEW_BRANCH" == "$BRANCH" ] && echo "ERROR: Can't create a new branch with the same name as current branch" && break

        git remote set-url origin $REPO_SSH || FAILED="True"
        [ "$FAILED" == "False" ] && ssh-agent sh -c "ssh-add $SSH_KEY_PRIV_PATH ; git checkout -b $NEW_BRANCH $BRANCH" || FAILED="True"
        [ "$FAILED" == "True" ] && echo "ERROR: Failed to create new branch" && break

        echo "SUCCESS: New branch was created" && break
    elif [ "${OPTION,,}" == "w" ] ; then
        break
    elif [ "${OPTION,,}" == "x" ] ; then
        exit 0
    fi
done

read -d'' -s -n1 -p 'Press any key to continue...'
sleep 1
source $KIRA_MANAGER/git-manager.sh "$REPO_SSH" "$REPO_HTTPS" "$BRANCH" "$DIRECTORY" "$BRANCH_ENVAR"

# TODO: Check if below commands can be fully ommited 
# git config --global user.name github-username
# git config --global user.email github@email
# ssh-agent -s 
# eval `ssh-agent -s`
# ssh-add $SSH_KEY_PRIV_PATH