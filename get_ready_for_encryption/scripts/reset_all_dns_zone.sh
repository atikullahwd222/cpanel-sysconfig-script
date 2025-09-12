#!/bin/bash
# Auto reset DNS zones for all cPanel domains (modern cPanel)
# Enhanced to use WHM API resetzone instead of delete/add for proper reset without deletion
# Handles all domains including addons/parked via /etc/trueuserdomains
# Moved named restart outside loop for efficiency
# Added basic error checking

BACKUP_DIR="/root/dnsbackup_$(date +%F_%H%M)"
mkdir -p "$BACKUP_DIR"

echo "📦 Backing up all DNS zones to $BACKUP_DIR..."
cp /var/named/*.db "$BACKUP_DIR/" || { echo "❌ Backup failed!"; exit 1; }

# Get all unique domains from /etc/trueuserdomains
domains=$(awk -F: '{gsub(/ /,"",$1); if ($1) print $1}' /etc/trueuserdomains | sort -u)

for domain in $domains; do
    if [ -n "$domain" ]; then
        echo "🔄 Resetting DNS zone for $domain"

        # Reset zone using WHM API
        if /usr/local/cpanel/bin/whmapi1 resetzone domain="$domain" >/dev/null 2>&1; then
            echo "✅ Zone reset successfully"
        else
            echo "❌ Error: Failed to reset zone for $domain"
        fi

        echo "✅ $domain done"
    fi
done

# Reload named once at the end
if /scripts/restartsrv_named >/dev/null 2>&1; then
    echo "🔄 named service restarted successfully"
else
    echo "⚠️ Warning: Failed to restart named service"
fi

echo "🎉 All DNS zones reset. Backup saved in $BACKUP_DIR"