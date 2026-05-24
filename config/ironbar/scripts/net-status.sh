#!/bin/bash

# Simple script to calculate network speed
# Usage: ./net-status.sh

interface=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}' | head -n1)

if [ -z "$interface" ]; then
    echo "󰤭 Offline"
    exit 0
fi

# Initial values
R1=$(cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null || echo 0)
T1=$(cat /sys/class/net/$interface/statistics/tx_bytes 2>/dev/null || echo 0)

sleep 1

# New values
R2=$(cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null || echo 0)
T2=$(cat /sys/class/net/$interface/statistics/tx_bytes 2>/dev/null || echo 0)

# Calculate difference
TBPS=$((T2 - T1))
RBPS=$((R2 - R1))

function format_speed {
    if [ $1 -ge 1048576 ]; then
        awk "BEGIN {printf \"%.1f MB/s\", $1/1048576}"
    elif [ $1 -ge 1024 ]; then
        awk "BEGIN {printf \"%.0f KB/s\", $1/1024}"
    else
        echo "$1 B/s"
    fi
}

echo "󰁅 $(format_speed $RBPS)  󰁝 $(format_speed $TBPS)"
