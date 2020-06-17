#!/bin/bash

exec 2>&1
set -e

OPERATION=$1
FILE=$2

[ -z "$OPERATION" ] && OPERATION="+0/0;0"

LEN=$( cut -d ';' -f 2- <<< "$OPERATION" )
OPERATION=$( cut -d ';' -f 1 <<< "$OPERATION" )
MAX=$( cut -d '/' -f 2- <<< "$OPERATION" )
OPERATION=$( cut -d '/' -f 1 <<< "$OPERATION" )

[ -z "$FILE" ] && FILE="/tmp/loader"
[ ! -f "$FILE" ] && touch $FILE

VALUE=$(cat $FILE)
[ -z "${VALUE##*[!0-9]*}" ] && VALUE=0
[ -z "${MAX##*[!0-9]*}" ] && MAX=0
[ -z "${LEN##*[!0-9]*}" ] && LEN=0
let "RESULT=${VALUE}${OPERATION}"
[ "$VALUE" != "$RESULT" ] && echo "$RESULT" > $FILE

if [ $MAX -ge 1 ] ; then
    let "PERCENTAGE=(100*$RESULT)/$MAX"

    if [ $LEN -le 0 ] ; then
        printf "%s%%" "${PERCENTAGE}"
    else
        let "COUNT_BLACK=($LEN*$RESULT)/$MAX"
        let "COUNT_WHITE=$LEN-$COUNT_BLACK-1"
        BLACK=$(printf "%${COUNT_BLACK}s" | tr " " "#")
        WHITE=$(printf "%${COUNT_WHITE}s" | tr " " ".")

        echo -ne "$BLACK-$WHITE (100%)\r" && sleep 0.10
        echo -ne "$BLACK\\$WHITE (100%)\r" && sleep 0.15
        echo -ne "$BLACK|$WHITE (100%)\r" && sleep 0.15
        echo -ne "$BLACK/$WHITE (100%)\r" && sleep 0.15
        echo -ne "$BLACK-$WHITE (100%)\r" && sleep 0.15
        echo -ne "$BLACK\\$WHITE (100%)\r" && sleep 0.15
        echo -ne "$BLACK|$WHITE (100%)\r" && sleep 0.15
    fi
fi