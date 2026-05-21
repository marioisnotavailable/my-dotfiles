#!/bin/bash
if ls /sys/class/power_supply/ | grep -qi '^BAT'; then
    printf "true"
else
    printf "false"
fi
