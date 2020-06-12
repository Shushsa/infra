#!/bin/bash

exec 2>&1
set -e
set -x

# (rm -fv $KIRA_INFRA/docker/validator/scripts/export-account.sh) && nano $KIRA_INFRA/docker/validator/scripts/export-account.sh

NAME=$1
OUTPUT=$2
KEYRINGPASS=$3
PASSPHRASE=$4

ACC_ADDR=$(echo ${KEYRINGPASS} | sekaicli keys show "$NAME" -a || echo "Error")

if [ "$ACC_ADDR" == "Error" ] ; then
    echo "ERROR: Export failed because account '$NAME' does NOT exists"
fi

OUTPUT=$(realpath $OUTPUT)
DIRECTORY=$(dirname $OUTPUT)
mkdir -p $DIRECTORY

rm -f $OUTPUT
sekaicli keys export $NAME -o text > $OUTPUT 2>&1 << EOF
$PASSPHRASE
$KEYRINGPASS
EOF

result=$(cat $OUTPUT)

if [ -z "$result" ] ; then
    echo "ERROR: Failed to export account '$NAME' into '$OUTPUT' file"
    exit 1
fi

echo "SUCCESS: Account '$NAME' was exported into '$OUTPUT' file"
