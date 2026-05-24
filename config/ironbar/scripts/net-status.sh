#!/bin/bash

# Function to convert bytes to human readable format with FIXED 10-character width
function format_speed {
    if [ $1 -ge 1048576 ]; then
        awk "BEGIN {printf \"%5.1f MB/s\", $1/1048576}"
    elif [ $1 -ge 1024 ]; then
        awk "BEGIN {printf \"%5.0f KB/s\", $1/1024}"
    else
        awk "BEGIN {printf \"%5.0f  B/s\", $1}"
    fi
}

RBPS=$(cat /sys/class/net/[ew]*/statistics/rx_bytes | awk '{s+=$1} END {print s}')
TBPS=$(cat /sys/class/net/[ew]*/statistics/tx_bytes | awk '{s+=$1} END {print s}')

sleep 1

RBPS_NEW=$(cat /sys/class/net/[ew]*/statistics/rx_bytes | awk '{s+=$1} END {print s}')
TBPS_NEW=$(cat /sys/class/net/[ew]*/statistics/tx_bytes | awk '{s+=$1} END {print s}')

RBPS=$((RBPS_NEW - RBPS))
TBPS=$((TBPS_NEW - TBPS))

echo "↓ $(format_speed $RBPS)  ↑ $(format_speed $TBPS)"
