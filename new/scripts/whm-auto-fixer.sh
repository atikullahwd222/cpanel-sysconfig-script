#!/bin/bash

# ============================================================================
# Enhanced WHM Server Monitoring & Auto-Remediation Script
# ============================================================================
# This script monitors WHM (Web Host Manager) port 2087 accessibility from
# external networks and automatically remediates firewall issues when detected.
# Features:
# - Multi-endpoint port checking with fallback
# - Intelligent sampling and rate limiting
# - Telegram & Discord notifications
# - Automatic firewall remediation
# - Timezone enforcement
# - State tracking and logging
# ============================================================================

# --- Configuration (override via /etc/default/t4s_server_care or env) ---
LOGFILE="${LOGFILE:-/var/log/check-whm.log}"
STATE_FILE="${STATE_FILE:-/var/log/whm_status.state}"
LAST_FLUSH_FILE="${LAST_FLUSH_FILE:-/var/log/last_flush.timestamp}"
LAST_WARN_FILE="${LAST_WARN_FILE:-/var/log/last_warning.timestamp}"

# Check interval and sampling for accuracy
INTERVAL_SEC="${INTERVAL_SEC:-2}"
SAMPLE_ATTEMPTS="${SAMPLE_ATTEMPTS:-3}"
SAMPLE_SUCCESS="${SAMPLE_SUCCESS:-2}"

# --- Enhanced Port Checking Endpoints ---
# Primary port checker service (returns JSON)
PRIMARY_PORT_CHECKER="${PRIMARY_PORT_CHECKER:-https://portchecker.bdix.baharihost.com}"

# Fallback port checking services (comma-separated)
FALLBACK_CHECKERS="${FALLBACK_CHECKERS:-https://portchecker.co/check,https://canyouseeme.org}"

# Alternative: Direct TCP connection check (most reliable)
USE_DIRECT_CHECK="${USE_DIRECT_CHECK:-1}"

# Threshold in seconds to rate-limit remediation/alerts (default 2 hours)
THRESHOLD="${THRESHOLD:-7200}"

# Optional timezone enforcement
ENFORCE_TZ="${ENFORCE_TZ:-Asia/Dhaka}"
ENFORCE_TZ_ENABLED="${ENFORCE_TZ_ENABLED:-1}"

# Notification settings
ENABLE_TELEGRAM="${ENABLE_TELEGRAM:-1}"
ENABLE_DISCORD="${ENABLE_DISCORD:-1}"

# Load external config if present
if [ -r /etc/default/t4s_server_care ]; then
    # shellcheck source=/dev/null
    . /etc/default/t4s_server_care
fi

# --- Ensure timezone if enabled ---
if [ "${ENFORCE_TZ_ENABLED}" = "1" ]; then
    CURRENT_TZ=$(timedatectl show --property=Timezone --value 2>/dev/null || true)
    if [ -n "$CURRENT_TZ" ] && [ "$CURRENT_TZ" != "$ENFORCE_TZ" ]; then
        echo "$(date) - Timezone is $CURRENT_TZ, changing to $ENFORCE_TZ" >> "$LOGFILE"
        timedatectl set-timezone "$ENFORCE_TZ" 2>/dev/null || true
    fi
fi

# --- Telegram & Discord config ---
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-8173063501:AAG6zIL8f8xgQO7Bg-63rq_NdqKuGEoY8-E}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-7608411134}"
DISCORD_WEBHOOK_URL="${DISCORD_WEBHOOK_URL:-https://discord.com/api/webhooks/1415366330072436868/tq0nwZVIoJA00qhF314-Nuqhn3jwa8LgQYWNveHKfmOHMm1lOWuUwSL4xpNxohtvBzL_}"

# --- Function to send Telegram messages ---
send_telegram() {
    [ "${ENABLE_TELEGRAM}" != "1" ] && return 0
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
         -d chat_id="$TELEGRAM_CHAT_ID" \
         -d text="$message" \
         -d parse_mode="Markdown" >/dev/null 2>&1 || true
}

# --- Function to send Discord messages ---
send_discord() {
    [ "${ENABLE_DISCORD}" != "1" ] && return 0
    local message="$1"
    local payload
    payload=$(printf '%s' "$message" | sed ':a;N;$!ba;s/\n/\\n/g; s/"/\\"/g')
    curl -s -H "Content-Type: application/json" -X POST \
         -d "{\"content\": \"$payload\"}" "$DISCORD_WEBHOOK_URL" >/dev/null 2>&1 || true
}

# --- Manual 'resolved' notifier ---
if [ "$1" = "resolved" ]; then
    HOST=$(hostnamectl --static 2>/dev/null || hostname)
    IP=$(dig +short "$HOST" 2>/dev/null | tail -n1)
    [ -z "$IP" ] && IP=$(hostname -I | awk '{print $1}')
    
    RESOLVED_MESSAGE="🎉 *WHM Accessibility Issue Solved!* 🎉\n\n*Server:* $HOST ($IP)\n*Date:* $(date)\nThe WHM server is now accessible and fully operational ✅"
    RESOLVED_MESSAGE_DISCORD="# 🎉 WHM Accessibility Issue Solved! 🎉\n\n## **Server:** https://$HOST:2087 | $IP\n**Date:** $(date)\nThe WHM server is now accessible and fully operational ✅"
    
    echo "$(date) - Manual resolved trigger called for $HOST ($IP)" >> "$LOGFILE"
    send_telegram "$RESOLVED_MESSAGE"
    send_discord "$RESOLVED_MESSAGE_DISCORD"
    exit 0
fi

# --- Helper Functions ---
now_ts() { date +%s; }
read_ts() { [ -f "$1" ] && cat "$1" 2>/dev/null || echo 0; }

should_run() {
    local ts_file="$1"
    local threshold="$2"
    local now
    now=$(now_ts)
    local last
    last=$(read_ts "$ts_file")
    [ $(( now - last )) -ge "$threshold" ]
}

# --- Direct TCP connection check (most reliable method) ---
check_direct_tcp() {
    local host="$1"
    local port="${2:-2087}"
    local timeout="${3:-5}"
    
    # Try to establish TCP connection using multiple methods
    if command -v timeout >/dev/null 2>&1; then
        timeout "$timeout" bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null && echo 1 || echo 0
    elif command -v nc >/dev/null 2>&1; then
        nc -z -w "$timeout" "$host" "$port" >/dev/null 2>&1 && echo 1 || echo 0
    elif command -v telnet >/dev/null 2>&1; then
        (echo "quit" | timeout "$timeout" telnet "$host" "$port" 2>&1 | grep -q "Connected") && echo 1 || echo 0
    else
        echo 0
    fi
}

# --- Enhanced external reachability check ---
check_external_once() {
    local ip="$1"
    local port="${2:-2087}"
    
    # Method 1: Direct TCP check (most reliable)
    if [ "${USE_DIRECT_CHECK}" = "1" ]; then
        # Get public IP to test
        local pub_ip
        pub_ip=$(dig +short myip.opendns.com @resolver1.opendns.com 2>/dev/null | tail -n1)
        [ -z "$pub_ip" ] && pub_ip=$(curl -4 -s --max-time 3 ifconfig.me 2>/dev/null)
        
        if [ -n "$pub_ip" ]; then
            local result
            result=$(check_direct_tcp "$pub_ip" "$port" 5)
            if [ "$result" = "1" ]; then
                LAST_CHECK_DETAIL="direct_tcp:$pub_ip:$port:open"
                echo 1
                return 0
            fi
        fi
    fi
    
    # Method 2: Use primary port checker (baharihost.com JSON)
    local success=0
    local details=""
    local resp resp_json open_val time_val service_val method_val
    
    # Try primary checker first
    resp_json=$(curl -4 -s --max-time 6 "${PRIMARY_PORT_CHECKER}/?host=${ip}&port=${port}" 2>/dev/null)
    if echo "$resp_json" | grep -q '"open"\s*:\s*true'; then
        success=1
        # extract optional fields from JSON without jq
        time_val=$(printf "%s" "$resp_json" | sed -n 's/.*"time"\s*:\s*\([^,}]*\).*/\1/p' | head -n1)
        service_val=$(printf "%s" "$resp_json" | sed -n 's/.*"service"\s*:\s*"\([^"]*\)".*/\1/p' | head -n1)
        method_val=$(printf "%s" "$resp_json" | sed -n 's/.*"method"\s*:\s*"\([^"]*\)".*/\1/p' | head -n1)
        details="bdix:open time=${time_val:-na} service=${service_val:-na} method=${method_val:-na}"
        LAST_CHECK_DETAIL="$details"
        echo 1
        return 0
    else
        # include snippet for debugging
        details="bdix:${resp_json:-err}"
    fi
    
    # Method 3: Try fallback checkers if primary fails
    local urls_str
    urls_str=$(printf "%s" "$FALLBACK_CHECKERS" | sed 's/,/ /g')
    
    for url in $urls_str; do
        [ -z "$url" ] && continue
        
        local check_resp
        
        # Handle different checker formats
        if echo "$url" | grep -q "portchecker.co"; then
            check_resp=$(curl -4 -s --max-time 5 -X POST -d "port=$port" -d "host=$ip" "$url" 2>/dev/null | grep -o "open" || echo "closed")
            [ "$check_resp" = "open" ] && success=1
        elif echo "$url" | grep -q "canyouseeme.org"; then
            check_resp=$(curl -4 -s --max-time 5 "https://canyouseeme.org/" 2>/dev/null | grep -o "Success" || echo "Fail")
            [ "$check_resp" = "Success" ] && success=1
        else
            # Generic endpoint that returns "1" for open
            check_resp=$(curl -4 -s --max-time 5 "${url}?host=${ip}&port=${port}" 2>/dev/null)
            [ "$check_resp" = "1" ] && success=1
        fi
        
        details="$details,${url##*/}:${check_resp:-err}"
        
        # Break on first success
        [ "$success" = "1" ] && break
    done
    
    LAST_CHECK_DETAIL="${details:-no_check_performed}"
    echo "$success"
}

# --- Multi-sample reachability check with enhanced reliability ---
check_reachable() {
    local ip="$1"
    local port="${2:-2087}"
    local attempts="$SAMPLE_ATTEMPTS"
    local need="$SAMPLE_SUCCESS"
    local ok=0
    
    for i in $(seq 1 "$attempts"); do
        local result
        result=$(check_external_once "$ip" "$port")
        [ "$result" = "1" ] && ok=$((ok+1))
        [ "$ok" -ge "$need" ] && break
        sleep 0.4
    done
    
    # Record sampling stats for notifications
    LAST_SAMPLE_OK="$ok"
    LAST_SAMPLE_TOTAL="$attempts"
    LAST_CHECK_URL="${PRIMARY_PORT_CHECKER}"
    
    if [ "$ok" -ge "$need" ]; then
        echo 1
    else
        echo 0
    fi
}

# --- Comprehensive firewall remediation ---
remediate_firewall() {
    echo "$(date) - Starting comprehensive firewall remediation" >> "$LOGFILE"
    
    # 1. Run cPanel's firewall configuration script
    if [ -x /scripts/configure_firewall_for_cpanel ]; then
        echo "$(date) - Running cPanel firewall configuration" >> "$LOGFILE"
        /scripts/configure_firewall_for_cpanel >> "$LOGFILE" 2>&1 || true
    fi
    
    # 2. Restart cpsrvd service
    if [ -x /usr/local/cpanel/cpsrvd ]; then
        echo "$(date) - Restarting cpsrvd service" >> "$LOGFILE"
        /usr/local/cpanel/cpsrvd restart >> "$LOGFILE" 2>&1 || true
    fi
    
    # 3. Ensure critical ports are allowed in iptables
    echo "$(date) - Configuring iptables rules" >> "$LOGFILE"
    
    # Allow WHM port 2087
    iptables -C INPUT -p tcp --dport 2087 -j ACCEPT 2>/dev/null || \
        iptables -I INPUT -p tcp --dport 2087 -j ACCEPT 2>/dev/null || true
    
    # Allow cPanel port 2083
    iptables -C INPUT -p tcp --dport 2083 -j ACCEPT 2>/dev/null || \
        iptables -I INPUT -p tcp --dport 2083 -j ACCEPT 2>/dev/null || true
    
    # Ensure policies are ACCEPT
    iptables -P INPUT ACCEPT 2>/dev/null || true
    iptables -P FORWARD ACCEPT 2>/dev/null || true
    iptables -P OUTPUT ACCEPT 2>/dev/null || true
    
    # 4. Flush unnecessary NAT and mangle rules
    iptables -t nat -F 2>/dev/null || true
    iptables -t mangle -F 2>/dev/null || true
    
    # 5. Save iptables rules
    if command -v iptables-save >/dev/null 2>&1; then
        iptables-save > /etc/sysconfig/iptables 2>/dev/null || \
        iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
    fi
    
    # 6. Restart firewalld if present
    if systemctl is-active --quiet firewalld; then
        echo "$(date) - Restarting firewalld" >> "$LOGFILE"
        systemctl restart firewalld >> "$LOGFILE" 2>&1 || true
    fi
    
    # 7. Check and restart CSF if installed
    if [ -x /usr/sbin/csf ]; then
        echo "$(date) - Restarting CSF firewall" >> "$LOGFILE"
        /usr/sbin/csf -r >> "$LOGFILE" 2>&1 || true
    fi
    
    echo "$(date) - Firewall remediation completed" >> "$LOGFILE"
    echo "$(now_ts)" > "$LAST_FLUSH_FILE"
}

# --- Enhanced notification functions ---
notify_up() {
    local host="$1"
    local ip="$2"
    local pub_ip
    pub_ip=$(dig +short myip.opendns.com @resolver1.opendns.com 2>/dev/null | tail -n1)
    [ -z "$pub_ip" ] && pub_ip=$(curl -4 -s --max-time 3 ifconfig.me 2>/dev/null)
    
    local msg_tg="🎉 *WHM Accessibility Restored!* ✅\n\n*Server:* $host\n*Internal IP:* $ip\n*Public IP:* ${pub_ip:-unknown}\n*Date:* $(date '+%Y-%m-%d %H:%M:%S %Z')\n*Status:* Externally reachable\n*Check Method:* ${LAST_CHECK_URL}\n*Success Rate:* ${LAST_SAMPLE_OK}/${LAST_SAMPLE_TOTAL}\n*Details:* ${LAST_CHECK_DETAIL}"
    
    local msg_dc="# 🎉 WHM Accessibility Restored! ✅\n\n## **Server:** https://$host:2087\n**Internal IP:** $ip\n**Public IP:** ${pub_ip:-unknown}\n**Date:** $(date '+%Y-%m-%d %H:%M:%S %Z')\n**Status:** Externally reachable ✅\n**Check Method:** ${LAST_CHECK_URL}\n**Success Rate:** ${LAST_SAMPLE_OK}/${LAST_SAMPLE_TOTAL}\n**Details:** ${LAST_CHECK_DETAIL}"
    
    send_telegram "$msg_tg"
    send_discord "$msg_dc"
}

notify_down() {
    local host="$1"
    local ip="$2"
    local pub_ip
    pub_ip=$(dig +short myip.opendns.com @resolver1.opendns.com 2>/dev/null | tail -n1)
    [ -z "$pub_ip" ] && pub_ip=$(curl -4 -s --max-time 3 ifconfig.me 2>/dev/null)
    
    local msg_tg="🚨 *WHM Accessibility Critical Issue* 🚨\n\n*Server:* $host\n*Internal IP:* $ip\n*Public IP:* ${pub_ip:-unknown}\n*Date:* $(date '+%Y-%m-%d %H:%M:%S %Z')\n*Status:* Unreachable externally after remediation\n*Check Method:* ${LAST_CHECK_URL}\n*Failure Rate:* $((LAST_SAMPLE_TOTAL - LAST_SAMPLE_OK))/${LAST_SAMPLE_TOTAL} failed\n*Details:* ${LAST_CHECK_DETAIL}\n\n⚠️ *MANUAL INTERVENTION REQUIRED*"
    
    local msg_dc="# 🚨 WHM Accessibility Critical Issue 🚨\n\n## **Server:** https://$host:2087\n**Internal IP:** $ip\n**Public IP:** ${pub_ip:-unknown}\n**Date:** $(date '+%Y-%m-%d %H:%M:%S %Z')\n**Status:** Unreachable externally after remediation ❌\n**Check Method:** ${LAST_CHECK_URL}\n**Failure Rate:** $((LAST_SAMPLE_TOTAL - LAST_SAMPLE_OK))/${LAST_SAMPLE_TOTAL} failed\n**Details:** ${LAST_CHECK_DETAIL}\n\n## @everyone 🚨 MANUAL INTERVENTION REQUIRED"
    
    send_telegram "$msg_tg"
    send_discord "$msg_dc"
}

# --- Main monitoring loop ---
RUN_ONCE=${RUN_ONCE:-0}

echo "$(date) - WHM Monitoring Script Started (PID: $$)" >> "$LOGFILE"

while true; do
    # Get hostname and IP
    HOST=$(hostnamectl --static 2>/dev/null || hostname)
    IP=$(dig +short "$HOST" 2>/dev/null | tail -n1)
    
    # Fallback to local IP if DNS resolution fails
    if [ -z "$IP" ]; then
        IP=$(hostname -I 2>/dev/null | awk '{print $1}')
    fi
    
    if [ -z "$IP" ]; then
        echo "$(date) - ERROR: Could not determine server IP; retrying" >> "$LOGFILE"
        [ "$RUN_ONCE" = "1" ] && break
        sleep "$INTERVAL_SEC"
        continue
    fi
    
    # Read previous state
    local_status_file="$STATE_FILE"
    prev_status="$( [ -f "$local_status_file" ] && cat "$local_status_file" 2>/dev/null || echo unknown )"
    
    # Check reachability
    reachable=$(check_reachable "$IP" 2087)
    now=$(now_ts)
    
    if [ "$reachable" = "1" ]; then
        echo "$(date) - ✅ WHM is reachable externally on $IP ($HOST)" >> "$LOGFILE"
        echo up > "$local_status_file"
        
        # Notify only on state change
        if [ "$prev_status" != "up" ]; then
            notify_up "$HOST" "$IP"
        fi
    else
        echo "$(date) - ❌ WHM is NOT reachable externally on $IP ($HOST)" >> "$LOGFILE"
        echo down > "$local_status_file"
        
        # Attempt remediation if rate limit allows
        if should_run "$LAST_FLUSH_FILE" "$THRESHOLD"; then
            echo "$(date) - Initiating automatic remediation" >> "$LOGFILE"
            remediate_firewall
            
            # Wait a bit for services to stabilize
            sleep 3
            
            # Re-check after remediation
            reachable2=$(check_reachable "$IP" 2087)
            
            if [ "$reachable2" = "1" ]; then
                echo "$(date) - ✅ WHM reachable after remediation" >> "$LOGFILE"
                echo up > "$local_status_file"
                notify_up "$HOST" "$IP"
            else
                echo "$(date) - ❌ WHM still unreachable after remediation" >> "$LOGFILE"
                
                # Send warning if rate limit allows
                if should_run "$LAST_WARN_FILE" "$THRESHOLD"; then
                    notify_down "$HOST" "$IP"
                    echo "$now" > "$LAST_WARN_FILE"
                else
                    echo "$(date) - Warning notification suppressed (rate-limited)" >> "$LOGFILE"
                fi
            fi
        else
            echo "$(date) - Remediation skipped (rate-limited, last run: $(date -d @$(read_ts "$LAST_FLUSH_FILE")))" >> "$LOGFILE"
        fi
    fi
    
    # Break if running once
    [ "$RUN_ONCE" = "1" ] && break
    
    # Wait before next check
    sleep "$INTERVAL_SEC"
done

echo "$(date) - WHM Monitoring Script Stopped" >> "$LOGFILE"