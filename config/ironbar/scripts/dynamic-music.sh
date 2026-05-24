#!/bin/bash
status=$(playerctl status 2>/dev/null)
if [ "$status" != "Playing" ] && [ "$status" != "Paused" ]; then
    exit 0
fi

title=$(playerctl metadata title 2>/dev/null)
if [ -z "$title" ]; then
    exit 0
fi

# Count the total number of workspaces
workspace_count=$(niri msg workspaces | grep -c '^[ *]*[0-9]')

# Calculate dynamic maximum length based on open workspaces
# With 1 workspace, max_len is ~48
# With 17 workspaces, max_len is ~16
max_len=$(( 50 - (workspace_count * 2) ))
if [ "$max_len" -lt 10 ]; then max_len=10; fi

if [ "${#title}" -gt "$max_len" ]; then
    echo "${title:0:$max_len}… 󰎆"
else
    echo "$title 󰎆"
fi
