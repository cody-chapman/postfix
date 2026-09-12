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
MYHOSTNAME="${MYHOSTNAME:-westgate.bank}"
MYNETWORKS="${MYNETWORKS:-10.0.0.0/8}"
RELAYHOST="${RELAYHOST:-[westgate-bank.mail.protection.outlook.com]:25}"

# Overwrite /etc/postfix/main.cf dynamically
cat << EOF > /etc/postfix/main.cf
# Listen on all interfaces
inet_interfaces = all
inet_protocols = ipv4

# setting sane defaults
default_database_type = lmdb

# Identity
myhostname = ${MYHOSTNAME}
mydomain = ${MYHOSTNAME}
myorigin = \$mydomain

smtpd_banner = ESMTP

# Do not deliver locally
mydestination =

# Trusted Networks
mynetworks = ${MYNETWORKS}

# Container Logging Standard
maillog_file = /dev/stdout
compatibility_level = 3.6

# Relay Everything Through Microsoft 365
relayhost = ${RELAYHOST}

# SMTP Server header check hardening
header_checks = pcre:/etc/postfix/header_checks

# SMTP Server Restrictions
smtpd_relay_restrictions = 
    permit_mynetworks, 
    reject_unauth_destination

smtpd_recipient_restrictions = 
    permit_mynetworks, 
    reject_unauth_destination

# Set TLS up for connectivity
smtpd_tls_security_level = may
smtpd_tls_cert_file = /etc/ssl/certs/postfix.pem
smtpd_tls_key_file = /etc/ssl/private/postfix.key
smtp_tls_security_level = encrypt
# Following 2 settings are deprecated
#smtp_enforce_tls = yes
#smtp_use_tls = yes
smtp_tls_loglevel = 1

# Increase max size of emails and mailbox
message_size_limit = 52428800
mailbox_size_limit = 104857600
EOF

echo "--> Configuration file [main.cf] created successfully."

chown root:root /etc/postfix/main.cf


cat << EOF > /etc/postfix/header_checks
# Remove internal client Received headers (originating client info)
/^Received: from .* \(HELO .*\) \([^)]+\) by yourdomain\.com/ IGNORE
/^Received: from .* \[127\.0\.0\.1\]/ IGNORE
/^Received: from .* \[10\./ IGNORE
/^Received: from .* \[192\.168\./ IGNORE

# Remove client user agent, X-Mailer, and intermediate origin headers
/^User-Agent:/ IGNORE
/^X-Mailer:/ IGNORE
/^X-Originating-IP:/ IGNORE
/^X-Enigmail:/ IGNORE
/^X-PHP-Originating-Script:/ IGNORE
EOF

echo "--> Configuration file [header_checks] created successfully."

chown root:root /etc/postfix/header_checks

# Fixing issue with RHEL 10 default for lmdb vs hash
postconf -e "alias_maps = lmdb:/etc/aliases"
postconf -e "alias_database = lmdb:/etc/aliases"
newaliases

# Create tls certs to send emails securely
mkdir -p /etc/ssl/certs /etc/ssl/private
openssl req -new -x509 -nodes -days 365 \
  -out /etc/ssl/certs/postfix.pem \
  -keyout /etc/ssl/private/postfix.key \
  -subj "/C=US/ST=Nebraska/L=Omaha/O=Visiting Nurse Association/OU=Information Technology/CN=vnatoday.org"

chmod 600 /etc/ssl/private/postfix.key
chmod 644 /etc/ssl/certs/postfix.pem


# ----------------------------
# Validate configuration
# ----------------------------
echo "Checking Postfix [main.cf] configuration..."
postfix check || {
  echo "ERROR: Postfix configuration [main.cf] invalid"
  exit 1
}

echo "--> Starting Postfix daemon in foreground..."

# Start Postfix in foreground so the container stays alive
exec /usr/sbin/postfix start-fg
