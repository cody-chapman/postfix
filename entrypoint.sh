#!/bin/bash

set -euo pipefail

echo "=== Starting Postfix container ==="

# ----------------------------
# Timezone setup
# ----------------------------
if [ -n "${TZ:-}" ]; then
  ln -snf /usr/share/zoneinfo/"$TZ" /etc/localtime
  echo "$TZ" > /etc/timezone
  echo "Timezone set to $TZ"
fi

chown root:root /etc/postfix/main.cf /etc/postfix/allowed_hosts
chmod 644 /etc/postfix/main.cf /etc/postfix/allowed_hosts

# ----------------------------
# Environment export (optional for cron/tools)
# ----------------------------
printenv > /etc/environment

# ----------------------------
# Ensure Postfix runtime dirs exist
# ----------------------------
mkdir -p /var/spool/postfix /var/log/postfix

# ----------------------------
# Validate configuration
# ----------------------------
echo "Checking Postfix configuration..."
postfix check || {
  echo "ERROR: Postfix configuration invalid"
  exit 1
}

# ----------------------------
# Validate configuration
# ----------------------------
echo Hashing the allowed ip relay list
postmap /etc/postfix/allowed_hosts

echo Starting postfix
exec /usr/sbin/postfix start-fg
