#!/usr/bin/env bash
set -euo pipefail

wifi_active=$(nmcli -t -f TYPE,STATE dev 2>/dev/null | grep -m1 '^wifi:connected' || true)
ether_active=$(nmcli -t -f TYPE,STATE dev 2>/dev/null | grep -m1 '^ethernet:connected' || true)

if [ -n "$ether_active" ]; then
  echo "󰈀"
  exit 0
fi

if [ -n "$wifi_active" ]; then
  echo "󰖩"
  exit 0
fi

echo "󰖪"
