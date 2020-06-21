#!/bin/bash
set -e

INPUT=$1
DEBUG=$2

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

if [ $PROGRESS_PID -ge 1 ] ; then
    COMMAND=$(ps -o cmd fp $PROGRESS_PID || echo "")
else
    COMMAND=""
fi

COMMAND=`/bin/echo "$COMMAND" | /usr/bin/md5sum | /bin/cut -f1 -d" "`

PROGRESS_FILE="/tmp/loader"
PROGRESS_LEN=$(($PROGRESS_LEN-1))
PROGRESS_TIME=0
PROGRESS_TIME_FILE="${PROGRESS_FILE}_time"
PROGRESS_SPAN_FILE="${PROGRESS_FILE}_$COMMAND" # containes avg elapsed time from the previous run

touch $PROGRESS_FILE
touch $PROGRESS_TIME_FILE
touch $PROGRESS_SPAN_FILE

VALUE=$(cat $PROGRESS_FILE || echo "0")
[ -z "${VALUE##*[!0-9]*}" ] && VALUE=0

SPAN=$(cat $PROGRESS_SPAN_FILE || echo "0")
[ -z "${SPAN##*[!0-9]*}" ] && SPAN=0
[ $SPAN -le 0 ] && SPAN=3000
[ $SPAN -gt 9000 ] && SPAN=3000

let "RESULT=${VALUE}${OPERATION}" || RESULT=0
echo "$RESULT" > $PROGRESS_FILE || echo "ERROR: Failed to save result into progress file `$PROGRESS_FILE`"

PROGRESS_START_TIME="$(date -u +%s)"
if [ ! -f $PROGRESS_TIME_FILE ] || [ $RESULT -eq 0 ] ; then
    echo "$PROGRESS_START_TIME" > $PROGRESS_TIME_FILE || echo "ERROR: Failed to save time into progress time file `$PROGRESS_TIME_FILE`"
fi

[ $PROGRESS_MAX -le 0 ] && exit 0
let "PERCENTAGE_OLD=(100*$RESULT)/$PROGRESS_MAX" || PERCENTAGE_OLD=0

while : ; do
    RESULT=$(cat $PROGRESS_FILE || echo "0")
    [ -z "${RESULT##*[!0-9]*}" ] && RESULT=0

    PROGRESS_NOW_TIME="$(date -u +%s)"
    PROGRESS_START_TIME=$(cat $PROGRESS_TIME_FILE || echo $PROGRESS_NOW_TIME)
    [ -z "${PROGRESS_START_TIME##*[!0-9]*}" ] && PROGRESS_START_TIME=$PROGRESS_NOW_TIME
    PROGRESS_TIME=$((${PROGRESS_NOW_TIME}-${PROGRESS_START_TIME}))

    let "PERCENTAGE=(100*$RESULT)/$PROGRESS_MAX" || PERCENTAGE=0
    [ $PERCENTAGE -gt 100 ] && PERCENTAGE=100
    [ $PERCENTAGE -lt 0 ] && PERCENTAGE=0

    let "SPAN_PERCENTAGE=(100*$PROGRESS_TIME)/$SPAN" || SPAN_PERCENTAGE=$PERCENTAGE
    [ $SPAN_PERCENTAGE -gt 100 ] && SPAN_PERCENTAGE=100
    [ $SPAN_PERCENTAGE -lt 0 ] && SPAN_PERCENTAGE=0

    let "AVG_PERCENTAGE=((9*$PERCENTAGE)+$SPAN_PERCENTAGE)/10" || AVG_PERCENTAGE=0
    [ $AVG_PERCENTAGE -gt 100 ] && AVG_PERCENTAGE=100
    [ $AVG_PERCENTAGE -lt 0 ] && AVG_PERCENTAGE=0
    [ $AVG_PERCENTAGE -gt 1 ] && PERCENTAGE=$AVG_PERCENTAGE
    
    [ $PROGRESS_LEN -le 0 ] && printf "%s%%" "${PERCENTAGE}" && break

    [ "$PROGRESS_PID" != "0" ] && if ps -p $PROGRESS_PID > /dev/null ; then 
        [ $PERCENTAGE -ge 100 ] && PERCENTAGE=99
        CONTINUE="True"
    else
        PERCENTAGE=100
        CONTINUE="False"
    fi

    BLACK=""
    WHITE=""
    let "DELTA_PERCENTAGE=$PERCENTAGE-$PERCENTAGE_OLD" || DELTA_PERCENTAGE=0
    let "PROGRESS_SPEED=1000/(7*($DELTA_PERCENTAGE+1)" || PROGRESS_SPEED=10
    [ $PROGRESS_SPEED -lt 10 ] && PROGRESS_SPEED=10
    [ $PROGRESS_SPEED -lt 100 ] && PROGRESS_SPEED="0$PROGRESS_SPEED"

    for ((i=$PERCENTAGE_OLD;i<=$PERCENTAGE;i++)); do
        let "COUNT_BLACK=(($PROGRESS_LEN*$i)/100)-1" || COUNT_BLACK=0
        [ $COUNT_BLACK -gt $PROGRESS_LEN ] && COUNT_BLACK=$PROGRESS_LEN
        let "COUNT_WHITE=$PROGRESS_LEN-$COUNT_BLACK" || COUNT_WHITE=0
        [ $COUNT_WHITE -gt $PROGRESS_LEN ] && COUNT_WHITE=$PROGRESS_LEN
        
        [ $COUNT_BLACK -ge 1 ] && BLACK=$(printf "%${COUNT_BLACK}s" | tr " " "#")
        [ $COUNT_WHITE -eq 2 ] && WHITE="."
        [ $COUNT_WHITE -ge 3 ] && WHITE=$(printf "%${COUNT_WHITE}s" | tr " " ".")

        PROGRESS_NOW_TIME="$(date -u +%s)"
        PROGRESS_TIME=$((${PROGRESS_NOW_TIME}-${PROGRESS_START_TIME}))
         
        echo -ne "\r$BLACK-$WHITE ($i%|${PROGRESS_TIME}s)" && sleep "0.$PROGRESS_SPEED"
        echo -ne "\r$BLACK\\$WHITE ($i%|${PROGRESS_TIME}s)" && sleep "0.$PROGRESS_SPEED"
        echo -ne "\r$BLACK|$WHITE ($i%|${PROGRESS_TIME}s)" && sleep "0.$PROGRESS_SPEED"
        echo -ne "\r$BLACK/$WHITE ($i%|${PROGRESS_TIME}s)" && sleep "0.$PROGRESS_SPEED"
        echo -ne "\r$BLACK-$WHITE ($i%|${PROGRESS_TIME}s)" && sleep "0.$PROGRESS_SPEED"
        echo -ne "\r$BLACK\\$WHITE ($i%|${PROGRESS_TIME}s)" && sleep "0.$PROGRESS_SPEED"
        echo -ne "\r$BLACK|$WHITE ($i%|${PROGRESS_TIME}s)" && sleep "0.$PROGRESS_SPEED"
    done
     
    PERCENTAGE_OLD=$PERCENTAGE
    [ "$CONTINUE" == "True" ] && continue
    
    if [ "$PROGRESS_PID" != "0" ] && [ $PERCENTAGE -eq 100 ] ; then
        echo -ne "\r$BLACK#$WHITE ($PERCENTAGE%|${PROGRESS_TIME}s|${RESULT})"
        let "SPAN_AVG=($PROGRESS_TIME+$SPAN)/2" || SPAN_AVG=0
        echo "$SPAN_AVG" > $PROGRESS_SPAN_FILE
    else
        echo -ne "\r$BLACK#$WHITE ($PERCENTAGE%|${PROGRESS_TIME}s)"
    fi

    break
done