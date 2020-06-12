#!/bin/bash

exec 2>&1
set -e
set -x

# (rm -fv $KIRA_INFRA/docker/validator/scripts/add-account.sh) && nano $KIRA_INFRA/docker/validator/scripts/add-account.sh

NAME=$1
KEY=$2
KEYRINGPASS=$3
PASSPHRASE=$4

# check configs directory
[ ! -f "$KEY" ] && KEY="$SELF_CONFIGS/${KEY}"
[ ! -f "$KEY" ] && KEY="$SELF_CONFIGS/${KEY}.key" # use key as key filename
[ ! -f "$KEY" ] && KEY="$SELF_CONFIGS/${NAME}"
[ ! -f "$KEY" ] && KEY="$SELF_CONFIGS/${NAME}.key" # use name as key filename

# check common folder if still does not exists
[ ! -f "$KEY" ] && KEY="$COMMON_DIR/${KEY}"
[ ! -f "$KEY" ] && KEY="$COMMON_DIR/${KEY}.key" # use key as key filename
[ ! -f "$KEY" ] && KEY="$COMMON_DIR/${NAME}"
[ ! -f "$KEY" ] && KEY="$COMMON_DIR/${NAME}.key" # use name as key filename

if [ -f "$KEY" ] ; then
   echo "INFO: Key $NAME ($KEY) was found and will be imported..."
   #  NOTE: external variables: KEYRINGPASS, PASSPHRASE
   #  NOTE: Exporting: sekaicli keys export validator -o text
   #  NOTE: Deleting: sekaicli keys delete validator
   #  NOTE: Importing (first time requires to input keyring password twice):
   sekaicli keys import $NAME $KEY << EOF
$PASSPHRASE
$KEYRINGPASS
$KEYRINGPASS
EOF
else
   echo "WARNING: Generating NEW random $NAME key..."
   sekaicli keys add $NAME << EOF
$KEYRINGPASS
$KEYRINGPASS
EOF
fi