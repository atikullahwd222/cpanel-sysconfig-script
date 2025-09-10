#!/bin/bash

# --- Ensure timezone is Asia/Dhaka ---
CURRENT_TZ=$(timedatectl show --property=Timezone --value)
if [ "$CURRENT_TZ" != "Asia/Dhaka" ]; then
    echo "$(date) - Timezone is $CURRENT_TZ, changing to Asia/Dhaka" >> /var/log/check-whm.log
    timedatectl set-timezone Asia/Dhaka
fi

LOGFILE="/var/log/check-whm.log"

# --- Telegram & Discord config ---
TELEGRAM_BOT_TOKEN="8173063501:AAG6zIL8f8xgQO7Bg-63rq_NdqKuGEoY8-E"
TELEGRAM_CHAT_ID="7608411134"

DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1415366330072436868/tq0nwZVIoJA00qhF314-Nuqhn3jwa8LgQYWNveHKfmOHMm1lOWuUwSL4xpNxohtvBzL_"

# Threshold in seconds (2 hours)
THRESHOLD=7200

# --- Function to send Telegram messages ---
send_telegram() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
         -d chat_id="$TELEGRAM_CHAT_ID" \
         -d text="$message" \
         -d parse_mode="Markdown" >/dev/null 2>&1
}

# --- Function to send Discord messages ---
send_discord() {
    local message="$1"
    local payload
    payload=$(printf '%s' "$message" | sed ':a;N;$!ba;s/\n/\\n/g; s/"/\\"/g')
    curl -s -H "Content-Type: application/json" -X POST \
         -d "{\"content\": \"$payload\"}" "$DISCORD_WEBHOOK_URL" >/dev/null 2>&1
}

# --- Check if script called with "resolved" argument ---
if [ "$1" == "resolved" ]; then
    HOST=$(hostnamectl --static)
    IP=$(dig +short "$HOST" | tail -n1)

    RESOLVED_MESSAGE="🎉 *WHM Accessibility Issue Solved!* 🎉

*Server:* $HOST ($IP)
*Date:* $(date)
The WHM server is now accessible and fully operational ✅"

    RESOLVED_MESSAGE_DISCORD="# 🎉 *WHM Accessibility Issue Solved!* 🎉

## **Server:** https://$HOST:2087 | $IP
**Date:** $(date)
The WHM server is now accessible and fully operational ✅"

    echo "$(date) - Manual resolved trigger called, sending celebration message Server: $HOST ($IP)" >> "$LOGFILE"

    send_telegram "$RESOLVED_MESSAGE"
    send_discord "$RESOLVED_MESSAGE_DISCORD"

    exit 0
fi

# --- Main WHM check ---
HOST=$(hostnamectl --static)
IP=$(dig +short "$HOST" | tail -n1)

if [ -z "$IP" ]; then
    echo "$(date) - Could not resolve $HOST" >> "$LOGFILE"
    exit 1
fi

NOW=$(date +%s)

# Check external accessibility
EXTERNAL_RESPONSE=$(curl -4 -s --max-time 10 "http://portcheck.transmissionbt.com/2087")

if [ "$EXTERNAL_RESPONSE" = "1" ]; then
    echo "$(date) - WHM reachable externally on $IP ($HOST)" >> "$LOGFILE"
else
    echo "$(date) - WHM not reachable externally on $IP ($HOST) (response: $EXTERNAL_RESPONSE)" >> "$LOGFILE"

    # Check last flush
    if [ -f "/var/log/last_flush.timestamp" ]; then
        LAST_FLUSH=$(cat /var/log/last_flush.timestamp)
        TIME_SINCE_FLUSH=$((NOW - LAST_FLUSH))
    else
        TIME_SINCE_FLUSH=$THRESHOLD
    fi

    if [ $TIME_SINCE_FLUSH -ge $THRESHOLD ]; then
        echo "$(date) - Running firewall reset commands to attempt to fix external accessibility on $IP ($HOST)" >> "$LOGFILE"

        /scripts/configure_firewall_for_cpanel
        /usr/local/cpanel/cpsrvd
        iptables -P INPUT ACCEPT
        iptables -P FORWARD ACCEPT
        iptables -P OUTPUT ACCEPT
        iptables -t nat -F
        iptables -t mangle -F
        /usr/sbin/iptables -F
        /usr/sbin/iptables -X

        echo "$NOW" > /var/log/last_flush.timestamp

        # Re-check external accessibility
        EXTERNAL_RESPONSE2=$(curl -4 -s --max-time 10 "http://portcheck.transmissionbt.com/2087")

        if [ "$EXTERNAL_RESPONSE2" = "1" ]; then
            echo "$(date) - WHM now reachable externally on $IP ($HOST) after firewall reset" >> "$LOGFILE"

            SUCCESS_MESSAGE="🎉 *WHM Accessibility Resolved!* ✅

*Server:* $HOST ($IP)
*Date:* $(date)
*Action:* Firewall reset commands executed
*Result:* Now reachable externally
*Details:* The issue has been successfully resolved after resetting firewall rules."

            WARNING_MESSAGE_DISCORD="# 🎉 *WHM Accessibility Resolved!* ✅

## **Server:** https://$HOST:2087 | $IP
**Date:** $(date)
**Action:** Firewall reset commands executed
**Result:** Now reachable externally ✅
**Details:** The issue has been successfully resolved after resetting firewall rules."

            send_telegram "$SUCCESS_MESSAGE"
            send_discord "$WARNING_MESSAGE_DISCORD"

        else
            echo "$(date) - WHM still not reachable externally (response: $EXTERNAL_RESPONSE2) on $IP ($HOST) after firewall reset" >> "$LOGFILE"

            if [ -f "/var/log/last_warning.timestamp" ]; then
                LAST_WARNING=$(cat /var/log/last_warning.timestamp)
                TIME_SINCE_WARNING=$((NOW - LAST_WARNING))
            else
                TIME_SINCE_WARNING=$THRESHOLD
            fi

            if [ $TIME_SINCE_WARNING -ge $THRESHOLD ]; then
                WARNING_MESSAGE="⚠️ *WHM Accessibility Issue* ⚠️

*Server:* $HOST ($IP)
*Date:* $(date)
*Action:* Firewall reset commands attempted
*Result:* Still unreachable externally
*Response:* $EXTERNAL_RESPONSE2
*Details:* The firewall reset did not resolve the issue. Further investigation may be required."

                WARNING_MESSAGE_DISCORD="# ⚠️ *WHM Accessibility Issue* ⚠️

## **Server:** https://$HOST:2087 | $IP
**Date:** $(date)
**Action:** Firewall reset commands attempted
**Result:** Still unreachable externally
**Details:** The firewall reset did not resolve the issue.
## @everyone *Human Support required.*"

                send_telegram "$WARNING_MESSAGE"
                send_discord "$WARNING_MESSAGE_DISCORD"

                echo "$NOW" > /var/log/last_warning.timestamp
            fi
        fi
    else
        echo "$(date) - WHM not reachable externally on $IP ($HOST), but skipping firewall reset (last run $(date -d @$LAST_FLUSH))" >> "$LOGFILE"
    fi
fi
