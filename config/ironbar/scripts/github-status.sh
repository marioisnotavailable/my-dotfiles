#!/bin/bash
# Fetches GitHub status
status=$(curl -sf https://www.githubstatus.com/api/v2/status.json | jq -r '.status.indicator' 2>/dev/null)

if [ "$status" = "none" ]; then
    echo "  All Good"
elif [ -z "$status" ]; then
    echo "  Offline"
else
    echo "  Issues ($status)"
fi
