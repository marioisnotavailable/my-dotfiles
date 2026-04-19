# Arch Linux Niri + Zsh Dotfiles

This repository contains my automated dotfiles setup for Arch Linux, transitioning from an old X11/KDE/Hyprland environment to a clean, modern Wayland setup using the **Niri** window manager and **Zsh**.

## Features

- **Window Manager:** Niri (with native Nvidia Wayland support).
- **Shell:** Zsh powered by Oh My Zsh, with custom aliases (`yayf`, `whatsmyip`, `hb`) and native Arch plugins (autosuggestions, syntax-highlighting).
- **Terminal:** WezTerm (replacing Alacritty/Kitty).
- **Theming:** Dynamic wallpaper and system theming using `swww`, `matugen`, and the Elephant Lua menu suite.
- **Cleanup:** Automatically removes old X11/KDE bloat.
- **Hardware:** UDEV rules for PlatformIO, Wacom, and Xbox controllers.
- **IDEs:** Setup for CLion, DataGrip, VS Code Insiders.

## Prerequisites

- An Arch Linux system.
- Git (for cloning this repository).
- (Optional) Nvidia GPU setup will be handled dynamically via early-KMS in the script.

## Installation Guide

### Option 1: One-liner (via curl)

If you just want to bootstrap your system without manually cloning the repository first, you can run:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/marioisnotavailable/my-dotfiles/main/install.sh)"
```

### Option 2: Manual Clone

If you want to inspect the files before running the script:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/marioisnotavailable/my-dotfiles.git ~/my-dotfiles
   cd ~/my-dotfiles
   ```

2. **Run the installation script:**
   ```bash
   bash install.sh
   ```

## Post-Installation

1. The script will interactively ask for your Git credentials since they are not hardcoded.
2. Ensure you review the generated `Install_Script_Details.pdf` for a deep dive into what the script changes on your system.
3. **Log out** of your current session (or reboot).
4. Select **Niri** from your Display Manager (e.g., SDDM, GDM, or TTY).

---
*Generated and maintained automatically.*