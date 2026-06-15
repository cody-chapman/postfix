# Final image
FROM rockylinux/rockylinux:10-ubi

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
EXPOSE 25

# ENTRYPOINT ["/entrypoint.sh"]
