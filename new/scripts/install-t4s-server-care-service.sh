#!/bin/bash
set -euo pipefail

# Installer for systemd service to run the WHM Auto Fixer at boot
# - Installs script to /usr/local/bin/t4s_server_care
# - Creates /etc/default/t4s_server_care for configuration (if missing)
# - Creates/updates systemd unit t4s-server-care.service
# - Enables and starts the service

SERVICE_NAME="t4s-server-care.service"
BIN_PATH="/usr/local/bin/t4s_server_care"
ENV_FILE="/etc/default/t4s_server_care"
UNIT_PATH="/etc/systemd/system/${SERVICE_NAME}"
REPO_SCRIPT_PATH="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/new/scripts/whm-auto-fixer.sh"

require_root() {
  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    echo "This installer must be run as root." >&2
    exit 1
  fi
}

install_binary() {
  case "$REPO_SCRIPT_PATH" in
    http://*|https://*)
      echo "Downloading auto-fixer from: $REPO_SCRIPT_PATH"
      curl -fsSL "$REPO_SCRIPT_PATH" -o "$BIN_PATH"
      chmod 0755 "$BIN_PATH"
      ;;
    *)
      if [ ! -f "$REPO_SCRIPT_PATH" ]; then
        echo "Cannot find whm-auto-fixer.sh (looked at: $REPO_SCRIPT_PATH)" >&2
        exit 1
      fi
      install -m 0755 "$REPO_SCRIPT_PATH" "$BIN_PATH"
      ;;
  esac
  echo "Installed: $BIN_PATH"
}

create_env_file() {
  if [ -f "$ENV_FILE" ]; then
    echo "Using existing config: $ENV_FILE"
    return 0
  fi
  cat > "$ENV_FILE" << 'EOF'
# Configuration for t4s_server_care (systemd EnvironmentFile)
# Adjust and uncomment values as desired, then: systemctl restart t4s-server-care

# Interval and sampling
# INTERVAL_SEC=2
# SAMPLE_ATTEMPTS=3
# SAMPLE_SUCCESS=2

# Rate-limiting (seconds)
# THRESHOLD=7200

# Timezone enforcement
# ENFORCE_TZ_ENABLED=1
# ENFORCE_TZ=Asia/Dhaka

# External checkers (primary JSON + fallbacks)
# PRIMARY_PORT_CHECKER=https://portchecker.bdix.baharihost.com
# FALLBACK_CHECKERS=https://portchecker.co/check,https://canyouseeme.org
# USE_DIRECT_CHECK=1

# Logs and state files
# LOGFILE=/var/log/check-whm.log
# STATE_FILE=/var/log/whm_status.state
# LAST_FLUSH_FILE=/var/log/last_flush.timestamp
# LAST_WARN_FILE=/var/log/last_warning.timestamp

# Notifications
# ENABLE_TELEGRAM=1
# ENABLE_DISCORD=1
# TELEGRAM_BOT_TOKEN=REPLACE_ME
# TELEGRAM_CHAT_ID=REPLACE_ME
# DISCORD_WEBHOOK_URL=REPLACE_ME
EOF
  chmod 0644 "$ENV_FILE"
  echo "Created config: $ENV_FILE"
}

create_unit() {
  cat > "$UNIT_PATH" << EOF
[Unit]
Description=Theme4Sell WHM Auto Fixer (t4s_server_care)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
Group=root
EnvironmentFile=$ENV_FILE
ExecStart=$BIN_PATH
Restart=always
RestartSec=2
# Ensure a predictable environment
WorkingDirectory=/root
# Tighten a bit (optional; relax if needed)
NoNewPrivileges=true
MemoryAccounting=true
CPUAccounting=true

[Install]
WantedBy=multi-user.target
EOF
  chmod 0644 "$UNIT_PATH"
  echo "Created/updated unit: $UNIT_PATH"
}

reload_enable_start() {
  systemctl daemon-reload
  systemctl enable --now "$SERVICE_NAME"
  systemctl status --no-pager -n 20 "$SERVICE_NAME" || true
}

main() {
  require_root
  install_binary
  create_env_file
  create_unit
  reload_enable_start
  echo
  echo "Installation complete. Logs: tail -f /var/log/check-whm.log"
}

main "$@"
