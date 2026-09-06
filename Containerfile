# Final image
FROM registry.access.redhat.com/ubi10/ubi

# Install Postfix and dependencies (no EPEL needed)
RUN dnf install -y \
        postfix \
        postfix-lmdb \
        postfix-pcre \
        ca-certificates \
    && dnf clean all

# Create directories
RUN mkdir -p /var/spool/postfix /var/log/postfix

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose SMTP
EXPOSE 25

ENTRYPOINT ["/entrypoint.sh"]
