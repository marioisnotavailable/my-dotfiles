#!/bin/bash
DIR="$HOME/.config/ironbar/scripts"
REPO=$(cat "$DIR/current_repo.txt" 2>/dev/null)
if [ -z "$REPO" ]; then
    REPO="marioisnotavailable/my-dotfiles"
fi

# Fetch actions from GitHub API
JSON=$(curl -sf "https://api.github.com/repos/$REPO/actions/runs?per_page=1")

if [ -z "$JSON" ]; then
    # API failed or rate limited
    echo " ${REPO#*/}"
    exit 0
fi

COUNT=$(echo "$JSON" | jq -r '.total_count // 0')
if [ "$COUNT" = "0" ]; then
    echo " ${REPO#*/}"
    exit 0
fi

STATUS=$(echo "$JSON" | jq -r '.workflow_runs[0].status')
CONCLUSION=$(echo "$JSON" | jq -r '.workflow_runs[0].conclusion')

# Format Output (Pango markup for colors could be used, but keeping it simple)
if [ "$STATUS" = "completed" ]; then
    if [ "$CONCLUSION" = "success" ]; then
        echo " ${REPO#*/} "
    elif [ "$CONCLUSION" = "failure" ]; then
        echo " ${REPO#*/} "
    else
        echo " ${REPO#*/} "
    fi
else
    echo " ${REPO#*/} "
fi
