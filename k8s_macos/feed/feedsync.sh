#!/bin/sh
set -eu

echo "[feedsync] $(date -Is) starting as $(id -un)…"

# Ensure target dirs exist (works fine with fresh PVCs)
mkdir -p /var/lib/openvas/plugins /var/lib/notus || true

# (Optional) keep ownership friendly for other components that expect gvm
if id gvm >/dev/null 2>&1; then
  chown -R gvm:gvm /var/lib/openvas /var/lib/notus 2>/dev/null || true
fi

# If a TOML is mounted/baked for gvm, this is a sensible default path.
# We can override at runtime with env GREENBONE_FEED_SYNC_CONFIG.
export GREENBONE_FEED_SYNC_CONFIG="${GREENBONE_FEED_SYNC_CONFIG:-/home/gvm/.config/greenbone-feed-sync.toml}"

# Run both feeds (no user switching; runs as root — avoids setuid issues)
greenbone-feed-sync --type nasl
greenbone-feed-sync --type notus

# Readiness marker (useful for probes)
touch /var/lib/openvas/plugins/.feedsync_ready || true

echo "[feedsync] $(date -Is) done."
