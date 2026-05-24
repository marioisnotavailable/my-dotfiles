#!/bin/bash
IFACE=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5; exit}')
if [ -z "$IFACE" ]; then
    echo "󰤭 Offline"
    exit 0
fi

if [ ! -f "/sys/class/net/$IFACE/statistics/rx_bytes" ]; then
    echo "󰤭 Offline"
    exit 0
fi

R2=$(cat /sys/class/net/$IFACE/statistics/rx_bytes)
T2=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)
TIME2=$(date +%s%3N)

CACHE="/tmp/ironbar-net-$IFACE"
if [ -f "$CACHE" ]; then
    read R1 T1 TIME1 < "$CACHE"
    DT=$((TIME2 - TIME1))
    if [ "$DT" -gt 0 ]; then
        RBPS=$(( (R2 - R1) * 1000 / DT ))
        TBPS=$(( (T2 - T1) * 1000 / DT ))
    else
        RBPS=0
        TBPS=0
    fi
else
    RBPS=0
    TBPS=0
fi

echo "$R2 $T2 $TIME2" > "$CACHE"

function format_speed {
    if [ $1 -ge 1048576 ]; then
        awk "BEGIN {printf \"%5.1fM\", $1/1048576}"
    elif [ $1 -ge 1024 ]; then
        awk "BEGIN {printf \"%5.0fK\", $1/1024}"
    else
        awk "BEGIN {printf \"%5.0fB\", $1}"
    fi
}

echo "󰁅 $(format_speed $RBPS)  󰁝 $(format_speed $TBPS)"
