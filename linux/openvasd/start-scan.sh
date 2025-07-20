#!/bin/bash

# Usage: ./start-scan.sh
# Requires: curl, jq

SENSOR="localhost:3001"
TARGET="192.168.65.254"
PAYLOAD=$(jq -n \
  --arg host "$TARGET" \
  '{
    target: {
      hosts: [$host],
      excluded_hosts: [],
      ports: [],
      credentials: [],
      alive_test_ports: [],
      alive_test_methods: ["tcp_ack"],
      reverse_lookup_unify: false,
      reverse_lookup_only: false
    },
    port_range: "1-65535",
    alive_test: "tcp_ack",
    vts: []
  }')

echo "[+] Creating scan for $TARGET..."
SCAN_ID=$(curl -s -H "Content-Type: application/json" -d "$PAYLOAD" http://$SENSOR/scans | tr -d '"')
if [ -z "$SCAN_ID" ]; then
  echo "[-] Failed to create scan"
  exit 1
fi
echo "[+] Scan ID: $SCAN_ID"

# Wait for scan to become "stored"
echo "[*] Waiting for scan to be ready (status: stored)..."
while true; do
  STATUS=$(curl -s http://$SENSOR/scans/$SCAN_ID/status | jq -r '.status')
  echo "    current status: $STATUS"
  if [ "$STATUS" == "stored" ]; then
    break
  elif [ "$STATUS" == "failed" ]; then
    echo "[-] Scan initialization failed"
    exit 1
  fi
  sleep 1
done

# Start the scan
echo "[+] Starting scan..."
curl --fail-with-body -s -X POST -H "Content-Type: application/json" -d '{"action": "start"}' http://$SENSOR/scans/$SCAN_ID || exit 1

# Final status & usage info
echo "[✓] Scan started"
echo "Status:  curl http://$SENSOR/scans/$SCAN_ID/status"
echo "Results: curl http://$SENSOR/scans/$SCAN_ID/results"
