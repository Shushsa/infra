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

VALUE=$(cat $FILE)
[ -z "${VALUE##*[!0-9]*}" ] && VALUE=0
let "RESULT=${VALUE}${OPERATION}" || :
[ "$VALUE" != "$RESULT" ] && echo "$RESULT" > $FILE
[ $RESULT -eq 0 ] && echo "$(date -u +%s)" > "${FILE}_time" && TIME=0

while : ; do
    RESULT=$(cat $FILE)
    [ $RESULT -ge 1 ] && TIME=$(($(date -u +%s)-$(cat "${FILE}_time")))

    if [ $MAX -ge 1 ] ; then
        let "PERCENTAGE=(100*$RESULT)/$MAX"
        [ $PERCENTAGE -ge 100 ] && PERCENTAGE=100
        [ $PERCENTAGE -le 0 ] && PERCENTAGE=0
    
        if [ $LEN -le 0 ] ; then
            printf "%s%%" "${PERCENTAGE}"
        else
            let "COUNT_BLACK=($LEN*$RESULT)/$MAX" || :
            let "COUNT_WHITE=$LEN-$COUNT_BLACK-1" || :
            BLACK=$(printf "%${COUNT_BLACK}s" | tr " " "#")
            WHITE=$(printf "%${COUNT_WHITE}s" | tr " " ".")
    
            echo -ne "\r$BLACK-$WHITE ($PERCENTAGE%|${TIME}s)" && sleep 0.15
            echo -ne "\r$BLACK\\$WHITE ($PERCENTAGE%|${TIME}s)" && sleep 0.15
            echo -ne "\r$BLACK|$WHITE ($PERCENTAGE%|${TIME}s)" && sleep 0.15
            echo -ne "\r$BLACK/$WHITE ($PERCENTAGE%|${TIME}s)" && sleep 0.15
            echo -ne "\r$BLACK-$WHITE ($PERCENTAGE%|${TIME}s)" && sleep 0.15
            echo -ne "\r$BLACK\\$WHITE ($PERCENTAGE%|${TIME}s)" && sleep 0.15
            echo -ne "\r$BLACK|$WHITE ($PERCENTAGE%|${TIME}s)" && sleep 0.15

            [ "$PID" != "0" ] && [ -d /proc/$PID ] && continue
            echo -ne "\r$BLACK#$WHITE ($PERCENTAGE%)" 
        fi
    fi
break
done