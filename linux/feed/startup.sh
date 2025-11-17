#!/bin/sh
set -e

USER_NAME="${RUN_AS_USER:-gvm}"
CMD_NASL="greenbone-feed-sync --type nasl"
CMD_NOTUS="greenbone-feed-sync --type notus"

echo "[INFO] Ensuring feed target directories exist..."
mkdir -p /var/lib/openvas/plugins /var/lib/notus

echo "[INFO] Fixing volume permissions..."
chown -R "$USER_NAME":"$USER_NAME" /var/lib/openvas /var/lib/notus || true

# helper to run a command as $USER_NAME using whatever is available
run_as_user() {
  if command -v gosu >/dev/null 2>&1; then
    exec_cmd="gosu $USER_NAME $*"
  elif command -v runuser >/dev/null 2>&1; then
    exec_cmd="runuser -u $USER_NAME -- $*"
  elif command -v su >/dev/null 2>&1; then
    # su needs the command as a single string
    exec_cmd="su -s /bin/sh -c \"$*\" $USER_NAME"
  else
    echo "[WARN] No gosu/runuser/su found; running as root."
    exec_cmd="$*"
  fi
  # shellcheck disable=SC2086
  sh -c "$exec_cmd"
}

echo "[INFO] Running greenbone-feed-sync for VTS (NASL plugins)…"
run_as_user $CMD_NASL

echo "[INFO] Running greenbone-feed-sync for Notus advisories…"
run_as_user $CMD_NOTUS

echo "[INFO] Feed sync completed successfully"
touch /var/lib/openvas/plugins/.feedsync_ready

# Keep container alive
echo "[INFO] Sleeping forever to keep container alive…"
exec tail -f /dev/null
