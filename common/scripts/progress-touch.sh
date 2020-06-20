#!/bin/bash

exec 2>&1
set -e

OPERATION=$1
MAX=$2
LEN=$3
PID=$4
FILE=$5

[ -z "$OPERATION" ] && OPERATION="+0"
[ -z "$FILE" ] && FILE="/tmp/loader"
[ ! -f "$FILE" ] && touch $FILE
[ -z "${MAX##*[!0-9]*}" ] && MAX=0
[ -z "${LEN##*[!0-9]*}" ] && LEN=0
[ -z "${PID##*[!0-9]*}" ] && PID=0

LEN=$(($LEN-1))
PROGRESS_TIME=0
PROGRESS_TIME_FILE="${FILE}_time"

VALUE=$(cat $FILE)
[ -z "${VALUE##*[!0-9]*}" ] && VALUE=0
let "RESULT=${VALUE}${OPERATION}" || :
echo "$RESULT" > $FILE

PROGRESS_START_TIME="$(date -u +%s)"
if [ ! -f $PROGRESS_TIME_FILE ] || [ $RESULT -eq 0 ] ; then
    echo "$PROGRESS_START_TIME" > $PROGRESS_TIME_FILE
fi

while : ; do
    [ $MAX -le 0 ] && break

    RESULT=$(cat $FILE)
    PROGRESS_START_TIME=$(cat $PROGRESS_TIME_FILE)
    PROGRESS_NOW_TIME="$(date -u +%s)"
    [ $RESULT -ge 1 ] && PROGRESS_TIME=$((${PROGRESS_NOW_TIME}-${PROGRESS_START_TIME}))

    let "PERCENTAGE=(100*$RESULT)/$MAX"
    [ $PERCENTAGE -ge 100 ] && PERCENTAGE=100
    [ $PERCENTAGE -le 0 ] && PERCENTAGE=0
    [ $LEN -le 0 ] && printf "%s%%" "${PERCENTAGE}" && break

    BLACK=""
    WHITE=""

    let "COUNT_BLACK=(($LEN*$RESULT)/$MAX)-1" || :
    [ $COUNT_BLACK -gt $LEN ] && COUNT_BLACK=$LEN
    let "COUNT_WHITE=$LEN-$COUNT_BLACK" || :
    [ $COUNT_WHITE -gt $LEN ] && COUNT_WHITE=$LEN
    
    [ $COUNT_BLACK -ge 1 ] && BLACK=$(printf "%${COUNT_BLACK}s" | tr " " "#")
    [ $COUNT_WHITE -eq 2 ] && WHITE="."
    [ $COUNT_WHITE -ge 3 ] && WHITE=$(printf "%${COUNT_WHITE}s" | tr " " ".")
     
    echo -ne "\r$BLACK-$WHITE ($PERCENTAGE%|${PROGRESS_TIME}s)" && sleep 0.15
    echo -ne "\r$BLACK\\$WHITE ($PERCENTAGE%|${PROGRESS_TIME}s)" && sleep 0.15
    echo -ne "\r$BLACK|$WHITE ($PERCENTAGE%|${PROGRESS_TIME}s)" && sleep 0.15
    echo -ne "\r$BLACK/$WHITE ($PERCENTAGE%|${PROGRESS_TIME}s)" && sleep 0.15
    echo -ne "\r$BLACK-$WHITE ($PERCENTAGE%|${PROGRESS_TIME}s)" && sleep 0.15
    echo -ne "\r$BLACK\\$WHITE ($PERCENTAGE%|${PROGRESS_TIME}s)" && sleep 0.15
    echo -ne "\r$BLACK|$WHITE ($PERCENTAGE%|${PROGRESS_TIME}s)" && sleep 0.15
     
    [ "$PID" != "0" ] && if ps -p $PID > /dev/null ; then continue ; fi
    echo -ne "\r$BLACK#$WHITE ($PERCENTAGE%|${PROGRESS_TIME}s)" 

    break
done