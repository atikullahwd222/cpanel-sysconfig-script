#!/bin/bash
set -euo pipefail

# Updater for t4s_server_care. Intended to be run by systemd timer.
# - Downloads latest script to a temp file
# - Validates basic syntax
# - Atomically installs if changed
# - Restarts service when updated

BIN_PATH="/usr/bin/t4s_server_care"
ENV_FILE="/etc/default/t4s_server_care"
SERVICE_NAME="t4s-server-care.service"
DEFAULT_UPDATE_URL="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/new/scripts/whm-auto-fixer.sh"
LOGFILE="/var/log/t4s_update.log"

# Load optional environment
if [ -r "$ENV_FILE" ]; then
  # shellcheck source=/dev/null
  . "$ENV_FILE"
fi

UPDATE_URL="${UPDATE_URL:-$DEFAULT_UPDATE_URL}"

log() { echo "$(date '+%Y-%m-%d %H:%M:%S %Z') $*" | tee -a "$LOGFILE" >/dev/null; }

require_root() {
  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    echo "Updater must be run as root" >&2
    exit 1
  fi
}

main() {
  require_root
  tmpfile=$(mktemp /tmp/t4s_update.XXXXXX)
  trap 'rm -f "$tmpfile"' EXIT

  log "Fetching latest script from $UPDATE_URL"
  if ! curl -fsSL "$UPDATE_URL" -o "$tmpfile"; then
    log "Download failed"
    exit 0
  fi

  # basic validation: non-empty and syntactically valid bash
  if [ ! -s "$tmpfile" ]; then
    log "Downloaded file is empty; aborting"
    exit 0
  fi
  if ! bash -n "$tmpfile" 2>/dev/null; then
    log "Shell syntax check failed; aborting"
    exit 0
  fi

  # Compare with current
  if [ -f "$BIN_PATH" ] && cmp -s "$tmpfile" "$BIN_PATH"; then
    log "No change detected"
    exit 0
  fi

  # Install atomically, keep backup
  backup="${BIN_PATH}.bak.$(date +%s)"
  if [ -f "$BIN_PATH" ]; then
    cp -f "$BIN_PATH" "$backup" || true
  fi
  install -m 0755 "$tmpfile" "$BIN_PATH"
  log "Installed new version to $BIN_PATH (backup: $backup)"

  # Restart service if active
  if systemctl is-enabled --quiet "$SERVICE_NAME" 2>/dev/null || systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
    systemctl restart "$SERVICE_NAME" || true
    log "Restarted $SERVICE_NAME"
  else
    log "$SERVICE_NAME not active/enabled; skipped restart"
  fi
}

main "$@"
