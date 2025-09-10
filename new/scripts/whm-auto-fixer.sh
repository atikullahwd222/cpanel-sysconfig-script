#!/bin/bash

# --- Ensure timezone is Asia/Dhaka ---
CURRENT_TZ=$(timedatectl show --property=Timezone --value)
if [ "$CURRENT_TZ" != "Asia/Dhaka" ]; then
    echo "$(date) - Timezone is $CURRENT_TZ, changing to Asia/Dhaka" >> /var/log/check-whm.log
    timedatectl set-timezone Asia/Dhaka
fi


# --- Check if script called with "resolved" argument ---
if [ "$1" == "resolved" ]; then
    HOST=$(hostnamectl --static)
    IP=$(dig +short "$HOST" | tail -n1)
    LOGFILE="/var/log/check-whm.log"
    
    RESOLVED_MESSAGE="🎉 **WHM Accessibility Issue Solved!** 🎉\n\n**Server:** $HOST ($IP)\n**Date:** $(date)\nThe WHM server is now accessible and fully operational ✅"
    
    echo "$(date) - Manual resolved trigger called, sending celebration message Server: $HOST ($IP)" >> "$LOGFILE"
    
    # Telegram
    TELEGRAM_BOT_TOKEN="8173063501:AAG6zIL8f8xgQO7Bg-63rq_NdqKuGEoY8-E"
    TELEGRAM_CHAT_ID="7608411134"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
         -d chat_id="$TELEGRAM_CHAT_ID" \
         -d text="$RESOLVED_MESSAGE" \
         -d parse_mode="Markdown" >/dev/null 2>&1
    
    # Discord
    DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1415366330072436868/tq0nwZVIoJA00qhF314-Nuqhn3jwa8LgQYWNveHKfmOHMm1lOWuUwSL4xpNxohtvBzL_"
    DISCORD_PAYLOAD="{\"content\": \"$(echo "$RESOLVED_MESSAGE" | sed 's/"/\\"/g')\"}"
    curl -s -H "Content-Type: application/json" -X POST -d "$DISCORD_PAYLOAD" "$DISCORD_WEBHOOK_URL" >/dev/null 2>&1
    
    exit 0
fi

# --- Rest of your existing WHM check script ---


# Get the hostname from system
HOST=$(hostnamectl --static)
IP=$(dig +short "$HOST" | tail -n1)
LOGFILE="/var/log/check-whm.log"
LAST_FLUSH_FILE="/var/log/last_flush.timestamp"
LAST_WARNING_FILE="/var/log/last_warning.timestamp"

# Telegram bot configuration
TELEGRAM_BOT_TOKEN="8173063501:AAG6zIL8f8xgQO7Bg-63rq_NdqKuGEoY8-E"  # Replace with your actual bot token
TELEGRAM_CHAT_ID="7608411134"      # Replace with your actual chat ID

# Discord webhook configuration
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1415366330072436868/tq0nwZVIoJA00qhF314-Nuqhn3jwa8LgQYWNveHKfmOHMm1lOWuUwSL4xpNxohtvBzL_"  # Replace with your actual Discord webhook URL

# Threshold in seconds (2 hours)
THRESHOLD=7200

if [ -z "$IP" ]; then
    echo "$(date) - Could not resolve $HOST" >> "$LOGFILE"
    exit 1
fi

# Current timestamp
NOW=$(date +%s)

# Check external accessibility
EXTERNAL_RESPONSE=$(curl -4 -s --max-time 10 "http://portcheck.transmissionbt.com/2087")

if [ "$EXTERNAL_RESPONSE" = "1" ]; then
    echo "$(date) - WHM reachable externally on $IP ($HOST)" >> "$LOGFILE"
else
    # Not reachable externally
    echo "$(date) - WHM not reachable externally on $IP ($HOST) (response: $EXTERNAL_RESPONSE)" >> "$LOGFILE"
    
    # Check last flush time
    if [ -f "$LAST_FLUSH_FILE" ]; then
        LAST_FLUSH=$(cat "$LAST_FLUSH_FILE")
        TIME_SINCE_FLUSH=$((NOW - LAST_FLUSH))
    else
        TIME_SINCE_FLUSH=$THRESHOLD  # Treat as eligible if no file
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
        echo "$NOW" > "$LAST_FLUSH_FILE"  # Update last flush timestamp
        
        # Check external again after firewall reset
        EXTERNAL_RESPONSE2=$(curl -4 -s --max-time 10 "http://portcheck.transmissionbt.com/2087")
        
        if [ "$EXTERNAL_RESPONSE2" = "1" ]; then
            # Now reachable externally, send success message
            echo "$(date) - WHM now reachable externally on $IP ($HOST) after firewall reset" >> "$LOGFILE"
            
            SUCCESS_MESSAGE="**WHM Accessibility Resolved** ✅\n\n**Server:** $HOST ($IP)\n**Date:** $(date)\n**Action:** Firewall reset commands executed\n**Result:** Now reachable externally\n**Details:** The issue has been successfully resolved after resetting firewall rules."
            
            # Send to Telegram
            curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
                 -d chat_id="$TELEGRAM_CHAT_ID" \
                 -d text="$SUCCESS_MESSAGE" \
                 -d parse_mode="Markdown" >/dev/null 2>&1
            
            # Send to Discord
            DISCORD_SUCCESS_PAYLOAD="{\"content\": \"$(echo -e "$SUCCESS_MESSAGE" | sed 's/"/\\"/g')\"}"
            curl -s -H "Content-Type: application/json" -X POST -d "$DISCORD_SUCCESS_PAYLOAD" "$DISCORD_WEBHOOK_URL" >/dev/null 2>&1
        else
            # Still not reachable externally, check last warning time
            echo "$(date) - WHM still not reachable externally (response: $EXTERNAL_RESPONSE2) on $IP ($HOST) after firewall reset" >> "$LOGFILE"
            
            if [ -f "$LAST_WARNING_FILE" ]; then
                LAST_WARNING=$(cat "$LAST_WARNING_FILE")
                TIME_SINCE_WARNING=$((NOW - LAST_WARNING))
            else
                TIME_SINCE_WARNING=$THRESHOLD  # Treat as eligible if no file
            fi
            
            if [ $TIME_SINCE_WARNING -ge $THRESHOLD ]; then
                WARNING_MESSAGE="**WHM Accessibility Issue** ⚠️\n\n**Server:** $HOST ($IP)\n**Date:** $(date)\n**Action:** Firewall reset commands attempted\n**Result:** Still unreachable externally\n**Response:** $EXTERNAL_RESPONSE2\n**Details:** The firewall reset did not resolve the issue. Further investigation may be required."
                
                # Send to Telegram
                curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
                     -d chat_id="$TELEGRAM_CHAT_ID" \
                     -d text="$WARNING_MESSAGE" \
                     -d parse_mode="Markdown" >/dev/null 2>&1
                
                # Send to Discord
                DISCORD_WARNING_PAYLOAD="{\"content\": \"$(echo -e "$WARNING_MESSAGE" | sed 's/"/\\"/g')\"}"
                curl -s -H "Content-Type: application/json" -X POST -d "$DISCORD_WARNING_PAYLOAD" "$DISCORD_WEBHOOK_URL" >/dev/null 2>&1
                
                echo "$NOW" > "$LAST_WARNING_FILE"  # Update last warning timestamp
            fi
        fi
    else
        echo "$(date) - WHM not reachable externally on $IP ($HOST), but skipping firewall reset (last run $(date -d @$LAST_FLUSH))" >> "$LOGFILE"
    fi
fi
