#!/bin/bash
DIR="$HOME/.config/ironbar/scripts"
LIST_FILE="$DIR/repo_list.txt"

# If the user presses Shift+Return in fuzzel, it outputs the raw typed text!
NEW_REPO=$(cat "$LIST_FILE" | fuzzel -d -p " Repo: ")

if [ -n "$NEW_REPO" ]; then
    # Write the new repo to current_repo.txt
    echo "$NEW_REPO" > "$DIR/current_repo.txt"
    
    # Check if it exists in list, if not append it
    if ! grep -Fxq "$NEW_REPO" "$LIST_FILE"; then
        echo "$NEW_REPO" >> "$LIST_FILE"
    fi
    
    # Reload ironbar to apply changes immediately
    ironbar reload
fi
