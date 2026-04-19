#!/bin/bash
# ============================================================
# Set Wallpaper via SWWW and Update Themes via Matugen
# ============================================================

IMAGE="$1"

if [ -z "$IMAGE" ]; then
    echo "Usage: $0 /path/to/image.png"
    exit 1
fi

# 1. Start swww daemon if not running
if ! pgrep -x swww-daemon > /dev/null; then
    swww-daemon &
    sleep 1
fi

# 2. Set the background image with a smooth wipe transition
swww img "$IMAGE" --transition-type wipe --transition-angle 30 --transition-step 90 --transition-fps 144

# 3. Create the symlinks for persistence (used by elephant and other scripts)
mkdir -p ~/.local/share/dotfiles/current
ln -nsf "$IMAGE" ~/.local/share/dotfiles/current/background

# 4. Generate colors with Matugen
echo "Running matugen..."
matugen image "$IMAGE"

# 5. Reload UI components to apply the new colors
echo "Reloading Waybar and Mako..."
makoctl reload 2>/dev/null || true
killall -SIGUSR2 waybar 2>/dev/null || true

# 6. Restart SwayOSD (if it needs to pick up the new CSS)
systemctl --user restart swayosd.service 2>/dev/null || true

echo "Done!"
