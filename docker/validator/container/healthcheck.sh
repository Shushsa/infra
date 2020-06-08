#!/bin/bash

exec 2>&1
set -e
set -x

EMAIL_SENT=$HOME/email_sent

echo "INFO: Healthcheck => START"
sleep 60 # rate limit

if [ "${MAINTENANCE_MODE}" == "true"  ] || [ -f "$MAINTENANCE_FILE" ] ; then
     echo "INFO: Entering maitenance mode!"
     exit 0
fi

# cleanup large files
find "/var/log/journal" -type f -size +256k -exec truncate --size=128k {} +
find "$SELF_LOGS" -type f -size +256k -exec truncate --size=128k {} +

if [ -f "$INIT_END_FILE" ] ; then
   echo "INFO: Initialization was successfull"
else
   echo "INFO: Pending initialization"
   exit 0
fi

RPC_STATUS="$(curl 127.0.0.1:$RPC_PROXY_PORT/status 2>/dev/null)" || RPC_STATUS="{}"
RPC_CATCHING_UP="$(echo $RPC_STATUS | jq -r '.result.sync_info.catching_up')" || RPC_CATCHING_UP="true"
STATUS_NGINX="$(systemctl2 is-active nginx.service)" || STATUS_RELAYER="unknown"
STATUS_SEKAI="$(systemctl2 is-active sekaid.service)" || STATUS_SEKAI="unknown"
STATUS_LCD="$(systemctl2 is-active lcd.service)" || STATUS_LCD="unknown"
STATUS_FAUCET="$(systemctl2 is-active faucet.service)" || STATUS_FAUCET="unknown"

# if [ "${STATUS_SEKAI}" != "active" ] || [ "${STATUS_LCD}" != "active" ] || [ "${STATUS_NGINX}" != "active" ] || [ "${STATUS_FAUCET}" != "active" ] ; then
if [ "${STATUS_SEKAI}" != "active" ] || [ "${STATUS_LCD}" != "active" ] || [ "${STATUS_NGINX}" != "active" ] ; then
    echo "ERROR: One of the services is NOT active: Sekai($STATUS_SEKAI), LCD($STATUS_LCD), Faucet($STATUS_FAUCET) or NGINX($STATUS_NGINX)"

    if [ "${STATUS_SEKAI}" != "active" ] ; then
        echo ">> Sekai log:"
        tail -n 100 /var/log/journal/sekaid.service.log || true
        systemctl2 restart sekaid || systemctl2 status sekaid.service || echo "Failed to re-start sekaid service" || true
    fi

    if [ "${STATUS_LCD}" != "active" ]  ; then
        echo ">> LCD log:"
        tail -n 100 /var/log/journal/lcd.service.log || true
        systemctl2 restart lcd || systemctl2 status lcd.service || echo "Failed to re-start lcd service" || true
    fi

    if [ "${STATUS_NGINX}" != "active" ]  ; then
        echo ">> NGINX log:"
        tail -n 100 /var/log/journal/nginx.service.log || true
        systemctl2 restart nginx || systemctl2 status nginx.service || echo "Failed to re-start nginx service" || true
    fi

    #if [ "${STATUS_FAUCET}" != "active" ]  ; then
    #    echo ">> Faucet log:"
    #    tail -n 100 /var/log/journal/faucet.nginx.log || true
    #    systemctl2 restart faucet || systemctl2 status faucet.service || echo "Failed to re-start faucet service" || true
    #fi

    if [ -f "$EMAIL_SENT" ] ; then
        echo "Notification Email was already sent."
    else
        echo "Sending Healthcheck Notification Email..."
        touch $EMAIL_SENT
        if [ "$NOTIFICATIONS" == "True" ] ; then
        CDHelper email send \
         --to="$EMAIL_NOTIFY" \
         --subject="[$MONIKER] Healthcheck Raised" \
         --body="[$(date)] Sekai($STATUS_SEKAI), Faucet($STATUS_FAUCET) LCD($STATUS_LCD) or NGINX($STATUS_NGINX) Failed => Attached $(find $SELF_LOGS -type f | wc -l) Log Files. RPC Status => $RPC_STATUS" \
         --html="false" \
         --recursive="true" \
         --attachments="$SELF_LOGS,$JOURNAL_LOGS"
        fi
        sleep 120 # allow user to grab log output
        rm -f ${SELF_LOGS}/healthcheck_script_output.txt # remove old log to save space
    fi
    exit 1  
else 
    echo "SUCCESS: All services are up and running!"
    if [ -f "$EMAIL_SENT" ] ; then
        echo "INFO: Sending confirmation email, that service recovered!"
        rm -f $EMAIL_SENT # if email was sent then remove and send new one
        if [ "$NOTIFICATIONS" == "True" ] ; then 
        CDHelper email send \
         --to="$EMAIL_NOTIFY" \
         --subject="[$MONIKER] Healthcheck Rerovered" \
         --body="[$(date)] Sekai($STATUS_SEKAI), Faucet($STATUS_FAUCET), LCD($STATUS_LCD) and NGINX($STATUS_NGINX) suceeded. RPC Status => $RPC_STATUS" \
         --html="false" || true
        fi
    fi
    sleep 120 # allow user to grab log output
    rm -f $SELF_LOGS/healthcheck_script_output.txt # remove old log to save space
fi

echo "INFO: Healthcheck => STOP"