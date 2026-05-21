#!/bin/bash
BAT=$(ls /sys/class/power_supply/ | grep -i "^BAT" | head -n 1)
if [ -z "$BAT" ]; then
    exit 0
fi

CAP=$(cat /sys/class/power_supply/$BAT/capacity 2>/dev/null)
STATUS=$(cat /sys/class/power_supply/$BAT/status 2>/dev/null)

if [ -z "$CAP" ]; then
    exit 0
fi

ICON="󰁹"
if [ "$STATUS" = "Charging" ]; then
    ICON="󰂄"
elif [ "$CAP" -le 20 ]; then
    ICON="󰂃"
elif [ "$CAP" -le 50 ]; then
    ICON="󰁾"
elif [ "$CAP" -le 80 ]; then
    ICON="󰂁"
fi

echo "$ICON $CAP%"
