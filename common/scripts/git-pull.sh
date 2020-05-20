#!/bin/bash

exec 2>&1
set -e
set -x

# Local Update Shortcut:
# (rm -fv $KIRA_SCRIPTS/git-pull.sh) && nano $KIRA_SCRIPTS/git-pull.sh && chmod 777 $KIRA_SCRIPTS/git-pull.sh

REPO=$1
BRANCH=$2
CHECKOUT=$3
OUTPUT=$4

echo "------------------------------------------------"
echo "|         STARTED: GIT PULL v0.0.1             |"
echo "------------------------------------------------"
echo "|  REPO:       $REPO"
echo "|  BRANCH:     $BRANCH"
echo "|  CHECKOUT:   $CHECKOUT"
echo "|  OUTPUT:     $OUTPUT"
echo "------------------------------------------------"

rm -rf $OUTPUT
mkdir -p $(dirname $OUTPUT)

if [ ! -z "$BRANCH" ]
then
    git clone --branch $BRANCH $REPO $OUTPUT
else
    git clone $REPO $OUTPUT
fi

cd $OUTPUT

if [ ! -z "$CHECKOUT" ]
then
    git checkout $CHECKOUT
fi   

git describe --tags || echo "No tags were found"
git describe --all --always

echo "------------------------------------------------"
echo "|         FINISHED: GIT PULL v0.0.1            |"
echo "------------------------------------------------"
