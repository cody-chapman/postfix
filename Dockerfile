# Final image
FROM registry.access.redhat.com/ubi10/ubi

# Install Postfix and dependencies (no EPEL needed)
RUN dnf install -y \
        postfix \
        postfix-lmdb \
        ca-certificates \
    && dnf clean all

# Create directories
RUN mkdir -p /var/spool/postfix /var/log/postfix

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose SMTP + UI ports
EXPOSE 25 587 465 8080

ENTRYPOINT ["/entrypoint.sh"]
