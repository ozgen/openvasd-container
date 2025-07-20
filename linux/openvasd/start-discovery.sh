#!/bin/sh
# To execute: ./start-discovery.sh <target>
# Example: SENSOR=<sensor> ./start-discovery.sh
[ -z "$SENSOR" ] && SENSOR="localhost:3001"
[ -z "$1" ] && TARGET="192.168.65.254" || TARGET="$1"
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

payload=$(sed "s/localhost/$TARGET/" "$SCRIPTPATH/discovery.json")
echo $payload
id=$(curl -s -H "Content-Type: application/json" -d "$payload" "$SENSOR/scans" | sed 's/"//g')
echo "Scan ID: $id"
curl --fail-with-body -s -H "Content-Type: application/json" -d '{"action": "start"}' "$SENSOR/scans/$id" || exit 1
echo "Status: curl --fail-with-body  \"$SENSOR/scans/$id/status\""
echo "Results: curl --fail-with-body  \"$SENSOR/scans/$id/results\""
