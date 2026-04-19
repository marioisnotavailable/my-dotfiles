#!/bin/bash

# ============================================================
# ARCH LINUX + NIRI + ZSH DOTFILES INSTALLER
# ============================================================

set -e

# Detect if the script is being run locally or via curl/wget
if [ -d "$HOME/.local/share/my-dotfiles" ]; then
    DOTFILES_DIR="$HOME/.local/share/my-dotfiles"
elif [ -d "$HOME/my-dotfiles" ]; then
    DOTFILES_DIR="$HOME/my-dotfiles"
else
    # If run via curl, we need to clone the repo first!
    echo "--> Running via curl/wget. Cloning dotfiles repository first..."
    DOTFILES_DIR="$HOME/.local/share/my-dotfiles"
    if [ ! -d "$DOTFILES_DIR" ]; then
        sudo pacman -Sy --noconfirm --needed git
        git clone https://github.com/marioisnotavailable/my-dotfiles.git "$DOTFILES_DIR"
    fi
fi

echo "========================================"
echo " Starting Niri + Zsh Installation"
echo " Dotfiles located at: $DOTFILES_DIR"
echo "========================================"
echo

# 1. Install YAY (AUR Helper)
install_yay() {
    if ! command -v yay &>/dev/null; then
        echo "--> Installing yay..."
        sudo pacman -S --noconfirm --needed git base-devel
        rm -rf /tmp/yay
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si --noconfirm
        cd ~
        rm -rf /tmp/yay
    else
        echo "--> yay is already installed."
    fi
}

# 2. Install Packages
install_packages() {
    echo "--> Installing packages..."
    local pkgs=(
        # Hardware & Core System Utilities
        zram-generator smartmontools hdparm ufw nss-mdns xpadneo-dkms wacomtablet
        
        # Base & Development
        base-devel git docker docker-compose npm python-pip python-setuptools python312 python-pynput pyenv jdk17-openjdk jre8-openjdk clang cmake ninja android-platform android-sdk android-sdk-build-tools android-sdk-cmdline-tools-latest android-sdk-platform-tools
        
        # Shell & Command Line Alternatives
        zsh starship zoxide fzf eza bat fd ripgrep jq pv yazi trash-cli unzip wget ncdu tree btop htop fastfetch gum mediainfo

        # Terminal Emulators
        wezterm

        # Web Browsers
        chromium firefox

        # File Managers
        nautilus yazi nautilus-open-any-terminal

        # Editors & IDEs
        neovim lazygit visual-studio-code-insiders-bin clion datagrip clion-jre datagrip-jre

        # Window Manager, Wayland Base & Theming
        niri fuzzel waybar mako dunst swayosd polkit-gnome gnome-keyring xdg-desktop-portal-gtk xdg-utils satty sunsetr tinte walker xar qt5ct qt6ct qt6-wayland matugen swww

        # Media & Screen (Screenshot, Images, Video)
        grim slurp wl-clipboard wl-paste imv mpv vlc yt-dlp ffmpeg imagemagick loupe gpu-screen-recorder handbrake-cli tesseract tesseract-data-eng

        # Audio & Volume Controls
        pipewire wireplumber pipewire-pulse pipewire-alsa pipewire-jack gst-plugin-pipewire pavucontrol pamixer wiremix playerctl libpulse

        # Network & Bluetooth
        network-manager-applet networkmanager bluez bluez-utils blueman bluetui iwd sshfs

        # System & File Utilities
        gvfs gvfs-dnssd udiskie pacman-contrib brightnessctl power-profiles-daemon plocate vmware-workstation vmware-keymaps cups hplip system-config-printer sbctl

        # Fonts & Themes
        noto-fonts noto-fonts-emoji ttf-cascadia-mono-nerd ttf-jetbrains-mono-nerd bibata-cursor-theme gnome-themes-extra otf-font-awesome yaru-icon-theme

        # Gaming & Launchers
        steam steam-devices heroic-games-launcher-bin modrinth-app-bin pandora-launcher-bin r2modman-bin balatro-mod-manager-bin

        # Elephant Suite
        elephant elephant-calc elephant-clipboard elephant-desktopapplications elephant-files elephant-menus elephant-providerlist elephant-symbols elephant-todo

        # Other Applications
        discord spotify libreoffice-fresh onlyoffice-bin keepassxc ollama localsend-bin kdeconnect kicad wireshark-qt krita aniworld-cli claude-code scilab-bin teams-for-linux-bin bambustudio-nvidia-bin github-desktop-bin beets picard strawberry high-tide impala input-leap-bin winboat-bin

        # Flatpak
        flatpak
    )
    
    yay -S --noconfirm --needed "${pkgs[@]}"

    echo "--> Installing Flatpaks..."
    flatpak install -y flathub com.usebottles.bottles org.vinegarhq.Sober || true
}

# 3. Configure Nvidia (If Present)
setup_nvidia() {
    if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
        echo "--> Nvidia GPU detected! Installing drivers and configuring Wayland..."
        yay -S --noconfirm --needed nvidia-dkms nvidia-utils nvidia-settings egl-wayland

        # Set Wayland environment variables for Nvidia
        mkdir -p "$HOME/.config/environment.d"
        cat > "$HOME/.config/environment.d/10-nvidia.conf" << 'EOF'
LIBVA_DRIVER_NAME=nvidia
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
WLR_NO_HARDWARE_CURSORS=1
EOF

        # Configure modprobe and mkinitcpio (early KMS) - Bootloader independent (works great for systemd-boot)
        echo "--> Configuring kernel modules (Early KMS for Nvidia)..."
        echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee /etc/modprobe.d/nvidia.conf > /dev/null
        
        # Ensure modules are added to mkinitcpio.conf
        sudo sed -i 's/^MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
        sudo sed -i 's/^MODULES=""/MODULES="nvidia nvidia_modeset nvidia_uvm nvidia_drm"/' /etc/mkinitcpio.conf
        
        # Check if modules were actually added, if not, append them properly
        if ! grep -q "nvidia_drm" /etc/mkinitcpio.conf; then
            # Replace empty or existing MODULES array with the Nvidia modules
            sudo sed -i 's/^MODULES=(.*)/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm \1)/' /etc/mkinitcpio.conf
        fi
        
        echo "--> Rebuilding initramfs..."
        sudo mkinitcpio -P

        echo "--> Nvidia configuration applied."
    else
        echo "--> No Nvidia GPU detected. Skipping Nvidia specific config."
    fi
}

# 4. Link Dotfiles
link_dotfiles() {
    echo "--> Linking dotfiles to ~/.config and ~/"

    mkdir -p "$HOME/.config"

    # Link everything in config/ to ~/.config/
    for config_dir in "$DOTFILES_DIR/config"/*; do
        if [ -d "$config_dir" ] || [ -f "$config_dir" ]; then
            target="$HOME/.config/$(basename "$config_dir")"
            if [ -e "$target" ] || [ -L "$target" ]; then
                echo "Backing up existing $target to $target.bak"
                rm -rf "$target.bak" 2>/dev/null || true
                mv "$target" "$target.bak"
            fi
            ln -s "$config_dir" "$target"
            echo "Linked $target -> $config_dir"
        fi
    done

    # Link everything in home/ to ~/
    for home_file in "$DOTFILES_DIR/home"/.*; do
        # Skip . and ..
        if [[ "$(basename "$home_file")" == "." || "$(basename "$home_file")" == ".." ]]; then
            continue
        fi

        if [ -f "$home_file" ]; then
            target="$HOME/$(basename "$home_file")"
            if [ -e "$target" ] || [ -L "$target" ]; then
                echo "Backing up existing $target to $target.bak"
                rm -rf "$target.bak" 2>/dev/null || true
                mv "$target" "$target.bak"
            fi
            ln -s "$home_file" "$target"
            echo "Linked $target -> $home_file"
        fi
    done
}

# 5. Change Default Shell
change_shell() {
    echo "--> Changing shell to Zsh..."
    if [ "$SHELL" != "$(which zsh)" ]; then
        chsh -s "$(which zsh)"
    fi
}

# 6. Configure Git
setup_git() {
    echo "--> Checking Git configuration..."
    local git_name
    local git_email

    if ! git config --global user.name >/dev/null 2>&1; then
        read -p "Enter your Git name (e.g., John Doe): " git_name
        git config --global user.name "$git_name"
    fi

    if ! git config --global user.email >/dev/null 2>&1; then
        read -p "Enter your Git email (e.g., john@example.com): " git_email
        git config --global user.email "$git_email"
    fi
    echo "--> Git is configured as: $(git config --global user.name) <$(git config --global user.email)>"
}

main() {
    install_yay
    install_packages
    setup_nvidia
    link_dotfiles
    change_shell
    setup_git
    
    echo "--> Configuring PlatformIO UDEV Rules..."
    curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/develop/platformio/assets/system/99-platformio-udev.rules | sudo tee /etc/udev/rules.d/99-platformio-udev.rules > /dev/null
    sudo udevadm control --reload-rules || true
    sudo udevadm trigger || true
    
    echo "--> Configuring Pacman Tweaks & Multilib..."
    sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
    sudo grep -q "^ILoveCandy" /etc/pacman.conf || sudo sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
    sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

    # Enable multilib for Steam and 32-bit gaming
    if grep -q "^#\[multilib\]" /etc/pacman.conf; then
        echo "Enabling [multilib] repository for Steam..."
        sudo sed -i '/^#\[multilib\]/{
N
s/^#\[multilib\]\n#Include/\[multilib\]\nInclude/
}' /etc/pacman.conf
        sudo pacman -Sy --noconfirm
    fi

    echo "--> Enabling User and Systemd Services..."
    systemctl --user daemon-reload || true
    systemctl --user enable --now walker.service swayosd.service elephant.service 2>/dev/null || true
    sudo systemctl enable --now cups.service
    
    echo
    echo "========================================"
    echo " Installation Complete!"
    echo " -> Reboot your system or log out."
    echo " -> Select 'Niri' from your display manager to start."
    echo "========================================"
}

main "$@"