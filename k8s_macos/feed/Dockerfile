FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV FEEDSYNC_VERSION=25.1.0
ENV TZ=Europe/Berlin

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg python3 python3-pip \
        cron rsync util-linux tzdata && \
    pip install "greenbone-feed-sync==${FEEDSYNC_VERSION}" --break-system-packages && \
    rm -rf /var/lib/apt/lists/*

# Keep the gvm user present (greenbone-feed-sync may drop privileges to it internally)
RUN groupadd --system gvm && \
    useradd  --system --create-home --gid gvm --shell /bin/bash gvm

# Data dirs (PVCs can mount here later)
# /var/lib/gvm is needed for /var/lib/gvm/feed-update.lock
RUN mkdir -p /var/lib/openvas/plugins /var/lib/notus /var/lib/gvm /app && \
    chown -R gvm:gvm /var/lib/openvas /var/lib/notus /var/lib/gvm || true && \
    chmod 0750 /var/lib/gvm || true

COPY feedsync.sh /usr/local/bin/feedsync.sh
COPY feedsync-cron /etc/cron.d/feedsync

RUN chmod +x /usr/local/bin/feedsync.sh && \
    chown root:root /etc/cron.d/feedsync && chmod 0644 /etc/cron.d/feedsync && \
    (tail -c1 /etc/cron.d/feedsync | od -An -t x1 | grep -q '0a' || echo >> /etc/cron.d/feedsync)

WORKDIR /app

CMD ["/bin/sh","-lc","/usr/local/bin/feedsync.sh || true; exec cron -f"]
