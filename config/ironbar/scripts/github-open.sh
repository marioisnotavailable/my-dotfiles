#!/bin/bash
DIR="$HOME/.config/ironbar/scripts"
REPO=$(cat "$DIR/current_repo.txt" 2>/dev/null)
if [ -n "$REPO" ]; then
    xdg-open "https://github.com/$REPO"
else
    xdg-open "https://github.com"
fi
