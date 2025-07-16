# Start from official OpenVAS scanner image
FROM registry.community.greenbone.net/community/openvas-scanner:stable

# Set working directory
WORKDIR /app

# ---- Install Redis ----
RUN apt update && \
    apt install --no-install-recommends --no-install-suggests -y redis-server && \
    mkdir -p /run/redis && \
    apt clean && rm -rf /var/lib/apt/lists/*

# ---- Redis Configuration (optional override) ----
COPY --from=registry.community.greenbone.net/community/redis-server /etc/redis/redis.conf /etc/redis/redis.conf

# ---- GPG Keyring ----
COPY --from=registry.community.greenbone.net/community/gpg-data /var/lib/greenbone/gpg /var/lib/greenbone/gpg

# ---- Configuration ----
COPY config.toml /etc/openvasd/openvasd.toml
COPY openvas.conf /etc/openvas/openvas.conf

# ---- Startup ----
COPY startup.sh /app/startup.sh
RUN chmod +x /app/startup.sh

ENTRYPOINT ["/app/startup.sh"]
