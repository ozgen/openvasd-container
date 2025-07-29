# Start from official OpenVAS scanner image
FROM registry.community.greenbone.net/community/openvas-scanner:stable

# Set working directory
WORKDIR /app

# ---- Install Redis and sudo ----
RUN apt update && \
    apt install --no-install-recommends --no-install-suggests -y redis-server sudo && \
    mkdir -p /run/redis && \
    apt clean && rm -rf /var/lib/apt/lists/*

# ---- Add gvm user ----
RUN useradd -ms /bin/bash gvm && \
    echo "gvm ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "Defaults secure_path += \"/usr/local/sbin\"" >> /etc/sudoers && \
    echo "Defaults env_keep += \"LD_LIBRARY_PATH\"" >> /etc/sudoers

# ---- Redis Configuration (optional override) ----
COPY --from=registry.community.greenbone.net/community/redis-server /etc/redis/redis.conf /etc/redis/redis.conf

# ---- GPG Keyring ----
COPY --from=registry.community.greenbone.net/community/gpg-data /var/lib/greenbone/gpg /var/lib/greenbone/gpg

# ---- Configuration ----
COPY config.toml /etc/openvasd/openvasd.toml

# ---- Startup ----
COPY startup.sh /app/startup.sh
RUN chmod +x /app/startup.sh

# ---- Set permissions ----
RUN mkdir -p /var/lib/openvas /run/redis /var/log && \
    chown -R gvm:gvm /var/lib/openvas /var/log /run/redis /var/lib/greenbone

# Default to root for startup, or change to `gvm` if needed
ENTRYPOINT ["/app/startup.sh"]
