FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV FEEDSYNC_VERSION=25.1.0

# Install deps + util-linux (provides runuser) + gosu (nicer than su)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg python3 python3-pip \
        cron rsync util-linux gosu && \
    pip install "greenbone-feed-sync==${FEEDSYNC_VERSION}" --break-system-packages && \
    rm -rf /var/lib/apt/lists/*

# Add gvm user and group
RUN groupadd --system gvm && \
    useradd --system --create-home --gid gvm --shell /bin/bash gvm

# Config for **gvm** (not root), logs & state dirs
RUN mkdir -p /home/gvm/.config /var/log/feedsync /opt/gvm/var/lib && \
    chown -R gvm:gvm /home/gvm /var/log/feedsync /opt/gvm

# Provide config to the user that will run the sync
COPY greenbone-feed-sync.toml /home/gvm/.config/greenbone-feed-sync.toml
RUN chown gvm:gvm /home/gvm/.config/greenbone-feed-sync.toml

# Cron job (cron.d format REQUIRES a user column)
# Runs 01:00 every day as 'gvm'
COPY feedsync-cron /etc/cron.d/feedsync-cron
RUN chmod 0644 /etc/cron.d/feedsync-cron && \
    crontab -r || true && \
    touch /var/log/cron.log

# Startup script starts cron in foreground so container stays alive
COPY startup.sh /app/startup.sh
RUN chmod +x /app/startup.sh

WORKDIR /app
ENTRYPOINT ["/app/startup.sh"]
