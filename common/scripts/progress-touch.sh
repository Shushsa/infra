#!/bin/bash

exec 2>&1
set -e

OPERATION=$1
PROGRESS_MAX=$2
PROGRESS_LEN=$3
PROGRESS_PID=$4
PROGRESS_FILE=$5

[ -z "$OPERATION" ] && OPERATION="+0"
[ -z "${PROGRESS_MAX##*[!0-9]*}" ] && PROGRESS_MAX=0
[ -z "${PROGRESS_LEN##*[!0-9]*}" ] && PROGRESS_LEN=0
[ -z "${PROGRESS_PID##*[!0-9]*}" ] && PROGRESS_PID=0

if [ ! -f "$PROGRESS_FILE" ] || [ -z "$PROGRESS_FILE" ] ; then
    PROGRESS_FILE="/tmp/loader"
fi

PROGRESS_LEN=$(($PROGRESS_LEN-1))
PROGRESS_TIME=0
PROGRESS_TIME_FILE="${PROGRESS_FILE}_time"

touch $PROGRESS_FILE
touch $PROGRESS_TIME_FILE

VALUE=$(cat $PROGRESS_FILE)
[ -z "${VALUE##*[!0-9]*}" ] && VALUE=0
let "RESULT=${VALUE}${OPERATION}" || :
echo "$RESULT" > $PROGRESS_FILE

PROGRESS_START_TIME="$(date -u +%s)"
if [ ! -f $PROGRESS_TIME_FILE ] || [ $RESULT -eq 0 ] ; then
    echo "$PROGRESS_START_TIME" > $PROGRESS_TIME_FILE
fi

while : ; do
    [ $PROGRESS_MAX -le 0 ] && break

    RESULT=$(cat $PROGRESS_FILE)
    PROGRESS_START_TIME=$(cat $PROGRESS_TIME_FILE)
    PROGRESS_NOW_TIME="$(date -u +%s)"
    [ $RESULT -ge 1 ] && PROGRESS_TIME=$((${PROGRESS_NOW_TIME}-${PROGRESS_START_TIME}))

    let "PERCENTAGE=(100*$RESULT)/$PROGRESS_MAX"
    [ $PERCENTAGE -ge 100 ] && PERCENTAGE=100
    [ $PERCENTAGE -le 0 ] && PERCENTAGE=0
    [ $PROGRESS_LEN -le 0 ] && printf "%s%%" "${PERCENTAGE}" && break

    BLACK=""
    WHITE=""

    let "COUNT_BLACK=(($PROGRESS_LEN*$RESULT)/$PROGRESS_MAX)-1" || :
    [ $COUNT_BLACK -gt $PROGRESS_LEN ] && COUNT_BLACK=$PROGRESS_LEN
    let "COUNT_WHITE=$PROGRESS_LEN-$COUNT_BLACK" || :
    [ $COUNT_WHITE -gt $PROGRESS_LEN ] && COUNT_WHITE=$PROGRESS_LEN
    
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
     
    [ "$PROGRESS_PID" != "0" ] && if ps -p $PROGRESS_PID > /dev/null ; then continue ; fi
    echo -ne "\r$BLACK#$WHITE ($PERCENTAGE%|${PROGRESS_TIME}s)" 

    break
done