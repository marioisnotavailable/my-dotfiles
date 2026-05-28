#!/bin/bash
if ls /sys/class/power_supply/ 2>/dev/null | grep -qi '^BAT'; then
    echo "true"
else
    echo "false"
fi
