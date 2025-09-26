FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV FEEDSYNC_VERSION=25.1.0
# Adjust if you prefer a different zone
ENV TZ=Europe/Berlin

# Install cron + deps and greenbone-feed-sync (Python package)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg python3 python3-pip \
        cron rsync util-linux tzdata && \
    pip install "greenbone-feed-sync==${FEEDSYNC_VERSION}" --break-system-packages && \
    rm -rf /var/lib/apt/lists/*

# Optional: keep the gvm user present (we DO NOT switch to it at runtime)
RUN groupadd --system gvm && \
    useradd  --system --create-home --gid gvm --shell /bin/bash gvm

# Data dirs (PVCs can mount here later)
RUN mkdir -p /var/lib/openvas/plugins /var/lib/notus /app && \
    chown -R gvm:gvm /var/lib/openvas /var/lib/notus || true

# Runner + cron job (system cron.d file)
COPY feedsync.sh /usr/local/bin/feedsync.sh
COPY feedsync-cron /etc/cron.d/feedsync
RUN chmod +x /usr/local/bin/feedsync.sh && \
    chown root:root /etc/cron.d/feedsync && chmod 0644 /etc/cron.d/feedsync && \
    # ensure trailing newline (cron is picky)
    (tail -c1 /etc/cron.d/feedsync | od -An -t x1 | grep -q '0a' || echo >> /etc/cron.d/feedsync)

WORKDIR /app

# One-shot run at boot (so you see logs immediately), then keep alive with cron -f
CMD ["/bin/sh","-lc","/usr/local/bin/feedsync.sh || true; exec cron -f"]
