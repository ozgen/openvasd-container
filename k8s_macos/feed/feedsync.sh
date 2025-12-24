#!/bin/sh
set -eu

echo "[feedsync] $(date -Is) starting as $(id -un)…"

# Ensure target dirs exist (works fine with fresh PVCs)
mkdir -p \
  /var/lib/openvas/plugins \
  /var/lib/notus \
  /var/lib/gvm || true

# /var/lib/gvm/feed-update.lock
if id gvm >/dev/null 2>&1; then
  chown -R gvm:gvm /var/lib/openvas /var/lib/notus /var/lib/gvm 2>/dev/null || true
  chmod 0750 /var/lib/gvm 2>/dev/null || true
fi

# If a TOML is mounted/baked for gvm, this is a sensible default path.
# We can override at runtime with env GREENBONE_FEED_SYNC_CONFIG.
export GREENBONE_FEED_SYNC_CONFIG="${GREENBONE_FEED_SYNC_CONFIG:-/home/gvm/.config/greenbone-feed-sync.toml}"

# Run feeds (even if invoked as root, greenbone-feed-sync may drop to 'gvm')
greenbone-feed-sync --type nasl
greenbone-feed-sync --type notus
greenbone-feed-sync --type report-format

# Readiness marker (useful for probes)
touch /var/lib/openvas/plugins/.feedsync_ready || true

echo "[feedsync] $(date -Is) done."
