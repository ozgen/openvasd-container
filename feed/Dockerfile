FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV FEEDSYNC_VERSION=25.1.0

RUN apt update && \
    apt install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        python3 \
        python3-pip \
        cron \
        rsync && \
    pip install greenbone-feed-sync==${FEEDSYNC_VERSION} --break-system-packages && \
    apt clean && rm -rf /var/lib/apt/lists/*

# 👇 Add gvm user and group
RUN groupadd --system gvm && \
    useradd --system --create-home --gid gvm --shell /bin/bash gvm

# Create needed directories
RUN mkdir -p /root/.config /var/log/feedsync /opt/gvm/var/lib

# Add config and scripts
COPY greenbone-feed-sync.toml /root/.config/greenbone-feed-sync.toml
COPY feedsync-cron /etc/cron.d/feedsync-cron
COPY startup.sh /app/startup.sh

RUN chmod +x /app/startup.sh && \
    chmod 0644 /etc/cron.d/feedsync-cron && \
    crontab /etc/cron.d/feedsync-cron

WORKDIR /app
ENTRYPOINT ["/app/startup.sh"]
