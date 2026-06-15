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

# ----------------------------
# Environment export (optional for cron/tools)
# ----------------------------
printenv > /etc/environment

# ----------------------------
# Ensure Postfix runtime dirs exist
# ----------------------------
mkdir -p /var/spool/postfix /var/log/postfix

# Fallback defaults if variables are not passed to the container
MYHOSTNAME="${MYHOSTNAME:-vnatoday.org}"
MYNETWORKS="${MYNETWORKS:-192.168.0.0/24 172.16.0.0/24}"
RELAYHOST="${RELAYHOST:-[://outlook.com]:25}"

echo "--> Generating main.cf dynamically via EOF..."

# Overwrite /etc/postfix/main.cf dynamically
cat << EOF > /etc/postfix/main.cf
# Listen on all interfaces
inet_interfaces = all
inet_protocols = ipv4

# Identity
myhostname = ${MYHOSTNAME}
mydomain = vnatoday.org
myorigin = \$mydomain

smtpd_banner = \$myhostname ESMTP \$mail_name

# Do not deliver locally
mydestination =

# Trusted Networks
mynetworks = ${MYNETWORKS}

# Container Logging Standard
maillog_file = stdout
compatibility_level = 3.6

# Relay Everything Through Microsoft 365
relayhost = ${RELAYHOST}

# SMTP Server Restrictions
smtpd_relay_restrictions = 
    permit_mynetworks, 
    reject_unauth_destination

smtpd_recipient_restrictions = 
    permit_mynetworks, 
    reject_unauth_destination
EOF

echo "--> Configuration file created successfully."

chown root:root /etc/postfix/main.cf

# ----------------------------
# Validate configuration
# ----------------------------
echo "Checking Postfix configuration..."
postfix check || {
  echo "ERROR: Postfix configuration invalid"
  exit 1
}

echo "--> Starting Postfix daemon in foreground..."

# Start Postfix in foreground so the container stays alive
exec postfix start-foreground

