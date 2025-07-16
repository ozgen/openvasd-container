#!/bin/bash
set -euo pipefail

REDIS_SOCKET_LOCATION="/run/redis/redis.sock"
LOG_LOCATION="/var/log/openvasd.log"

export GNUPGHOME="/var/lib/greenbone/gpg"

# Ensure necessary directories exist
mkdir -p /var/run/ospd /run/redis /var/log/notus-scanner /var/lib/notus/products /var/lib/openvas
# Ensure the log file exists before tailing
mkdir -p "$(dirname "$LOG_LOCATION")"
touch "$LOG_LOCATION"
chmod 644 "$LOG_LOCATION"

# Start Redis
echo "[INFO] Starting redis-server ..."
rm -f "$REDIS_SOCKET_LOCATION"
redis-server /etc/redis/redis.conf --daemonize yes

# Wait for Redis to be available
while ! [ -S "$REDIS_SOCKET_LOCATION" ]; do
  sleep 1
  echo "[INFO] Waiting for Redis socket..."
done
echo "[INFO] Redis-server is up and running!"

# Configure PORT if needed---
# Allow dynamic listener port injection
if [ -n "${OPENVASD_PORT:-}" ]; then
  echo "[INFO] Setting listener port to ${OPENVASD_PORT}..."
  sed -i "s/address = \".*\"/address = \"127.0.0.1:${OPENVASD_PORT}\"/" /etc/openvasd/openvasd.toml
fi

# Start OpenVASD
echo "[INFO] Starting openvasd ..."
openvasd \
  --config /etc/openvasd/openvasd.toml \
  --log-level=DEBUG &

sleep 2
echo "[INFO] OpenVASD is up and running!"

# Tail logs to keep the container running
tail -f "$LOG_LOCATION"
