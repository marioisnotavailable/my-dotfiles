#!/bin/bash
if ls /sys/class/power_supply/ 2>/dev/null | grep -qi '^BAT'; then
    exit 0
else
    exit 1
fi
