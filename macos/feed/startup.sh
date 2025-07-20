#!/bin/sh
set -e

echo "[INFO] Ensuring feed target directories exist..."
mkdir -p /var/lib/openvas/plugins /var/lib/notus

echo "[INFO] Fixing volume permissions..."
chown -R gvm:gvm /var/lib/openvas /var/lib/notus

echo "[INFO] Running greenbone-feed-sync for VTS (NASL plugins)..."
runuser -u gvm -- greenbone-feed-sync --type nasl

echo "[INFO] Running greenbone-feed-sync for Notus advisories..."
runuser -u gvm -- greenbone-feed-sync --type notus

echo "[INFO] Feed sync completed successfully"

echo "[INFO] Sleeping forever to keep container alive..."
tail -f /dev/null
