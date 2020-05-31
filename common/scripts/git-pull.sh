#!/bin/bash

exec 2>&1
set -e

# Local Update Shortcut:
# (rm -fv $KIRA_SCRIPTS/git-pull.sh) && nano $KIRA_SCRIPTS/git-pull.sh && chmod 777 $KIRA_SCRIPTS/git-pull.sh

REPO=$1
BRANCH=$2
OUTPUT=$3
RWXMOD=$4
SSHCRED=$5

if [[ $BRANCH =~ ^[0-9A-Fa-f]{1,}$ ]] ; then
    CHECKOUT=$BRANCH
    BRANCH="master"
else
    CHECKOUT=""
fi

[ -z "$RWXMOD" ] && RWXMOD=777
[ -z "$SSHCRED" ] && SSHCRED="/home/root/.ssh/id_rsa"

echo "------------------------------------------------"
echo "|         STARTED: GIT PULL v0.0.1             |"
echo "------------------------------------------------"
echo "|       REPO: $REPO"
echo "|     BRANCH: $BRANCH"
echo "|   CHECKOUT: $CHECKOUT"
echo "|     OUTPUT: $OUTPUT"
echo "|  R/W/X MOD: $RWXMOD"
echo "|   SSH CRED: $SSHCRED"
echo "------------------------------------------------"

if [[ (! -z "$REPO") && ( (! -z "$BRANCH") || (! -z "$CHECKOUT") ) && (! -z "$OUTPUT") ]] ; then
    echo "INFO: Valid repo details were specified, removing $OUTPUT and starting git pull..."
else
    [ -z "$REPO" ] && REPO=undefined
    [ -z "$BRANCH" ] && BRANCH=undefined
    [ -z "$CHECKOUT" ] && CHECKOUT=undefined
    [ -z "$OUTPUT" ] && OUTPUT=undefined
    echo "ERROR: REPO($REPO), BRANCH($BRANCH), CHECKOUT($CHECKOUT) or OUTPUT($OUTPUT) was NOT defined"
    exit 1
fi

# make sure not to delete user files if there are no permissions for user to pull
TMP_OUTPUT="/tmp/$OUTPUT"
rm -rf $TMP_OUTPUT
mkdir -p $TMP_OUTPUT
cd $TMP_OUTPUT

if [[ "${REPO,,}" == *"git@"*   ]] ; then
    echo "INFO: Detected https repo address"
    #git remote set-url origin $REPO

    if [ ! -z "$BRANCH" ] ; then
        ssh-agent sh -c "ssh-add $SSHCRED ; git clone --branch $BRANCH $REPO $TMP_OUTPUT"
    else
        ssh-agent sh -c "ssh-add $SSHCRED ; git clone $REPO $TMP_OUTPUT"
    fi

    git remote set-url origin $REPO

    if [ ! -z "$CHECKOUT" ] ; then
        ssh-agent sh -c "ssh-add $SSHCRED ; git checkout $CHECKOUT"
    fi
elif [[ "${REPO,,}" == *"https://"*   ]] ; then
    echo "INFO: Detected https repo address"
    if [ ! -z "$BRANCH" ] ; then
        git clone --branch $BRANCH $REPO $TMP_OUTPUT
    else
        git clone $REPO $TMP_OUTPUT
    fi

    if [ ! -z "$CHECKOUT" ] ; then
        git checkout $CHECKOUT
    fi
else
    echo "ERROR: Invalid repo address, should be either https (https://) or ssh (git@)"
    exit 1
fi

git describe --tags || echo "No tags were found"
git describe --all --always

rm -rf $OUTPUT
mkdir -p $OUTPUT
/bin/cp -rf "$TMP_OUTPUT/*" $OUTPUT

chmod -R $RWXMOD $OUTPUT

echo "------------------------------------------------"
echo "|         FINISHED: GIT PULL v0.0.1            |"
echo "------------------------------------------------"
