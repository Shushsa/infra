#!/bin/bash
set -e

INPUT=$1
PROGRESS_FILE=$2
DEBUG=$3

[ "$DEBUG" == "True" ] && set -x

ARR=(${INPUT//;/ })
OPERATION=${ARR[0]}
PROGRESS_MAX=${ARR[1]}
PROGRESS_LEN=${ARR[2]}
PROGRESS_PID=${ARR[3]}

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

VALUE=$(cat $PROGRESS_FILE || echo "0")
[ -z "${VALUE##*[!0-9]*}" ] && VALUE=0
let "RESULT=${VALUE}${OPERATION}" || RESULT=0
echo "$RESULT" > $PROGRESS_FILE || echo "ERROR: Failed to save result into progress file `$PROGRESS_FILE`"

PROGRESS_START_TIME="$(date -u +%s)"
if [ ! -f $PROGRESS_TIME_FILE ] || [ $RESULT -eq 0 ] ; then
    echo "$PROGRESS_START_TIME" > $PROGRESS_TIME_FILE || echo "ERROR: Failed to save time into progress time file `$PROGRESS_TIME_FILE`"
fi

while : ; do
    [ $PROGRESS_MAX -le 0 ] && break

    RESULT=$(cat $PROGRESS_FILE || echo "0")
    [ -z "${RESULT##*[!0-9]*}" ] && RESULT=0

    PROGRESS_NOW_TIME="$(date -u +%s)"
    PROGRESS_START_TIME=$(cat $PROGRESS_TIME_FILE || echo $PROGRESS_NOW_TIME)
    [ -z "${PROGRESS_START_TIME##*[!0-9]*}" ] && PROGRESS_START_TIME=$PROGRESS_NOW_TIME
    
    [ $RESULT -ge 1 ] && PROGRESS_TIME=$((${PROGRESS_NOW_TIME}-${PROGRESS_START_TIME}))

    let "PERCENTAGE=(100*$RESULT)/$PROGRESS_MAX" || PERCENTAGE=0
    [ $PERCENTAGE -gt 100 ] && PERCENTAGE=100
    [ $PERCENTAGE -lt 0 ] && PERCENTAGE=0
    [ $PROGRESS_LEN -le 0 ] && printf "%s%%" "${PERCENTAGE}" && break

    [ "$PROGRESS_PID" != "0" ] && if ps -p $PROGRESS_PID > /dev/null ; then 
        [ $PERCENTAGE -ge 100 ] && PERCENTAGE=99
        CONTINUE="True"
    else
        CONTINUE="False"
    fi

    BLACK=""
    WHITE=""

    let "COUNT_BLACK=(($PROGRESS_LEN*$RESULT)/$PROGRESS_MAX)-1" || COUNT_BLACK=0
    [ $COUNT_BLACK -gt $PROGRESS_LEN ] && COUNT_BLACK=$PROGRESS_LEN
    let "COUNT_WHITE=$PROGRESS_LEN-$COUNT_BLACK" || COUNT_WHITE=0
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
     
    [ "$CONTINUE" == "True" ] && continue
    echo -ne "\r$BLACK#$WHITE ($PERCENTAGE%|${PROGRESS_TIME}s)" 

    break
done