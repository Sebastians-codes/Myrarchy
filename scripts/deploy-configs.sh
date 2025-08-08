#!/bin/bash

# Hyprland Arch Setup - Configuration Deployment Script
# This script deploys all configuration files to their proper locations

set -e

echo "========================================="
echo "Hyprland Arch Setup - Config Deployment"
echo "========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$SETUP_DIR/configs"
WALLPAPER_DIR="$SETUP_DIR/wallpapers"

# Function to deploy config directory
deploy_config() {
    local source_dir="$1"
    local target_dir="$2"
    
    if [ -d "$source_dir" ]; then
        echo "Deploying $(basename "$source_dir") configuration..."
        mkdir -p "$(dirname "$target_dir")"
        cp -r "$source_dir" "$target_dir"
        echo "✓ $(basename "$source_dir") configuration deployed"
    else
        echo "⚠ Warning: $source_dir not found, skipping..."
    fi
}

# Create required directories
echo "Creating required directories..."
mkdir -p ~/.config
mkdir -p ~/Pictures/Screenshots
mkdir -p ~/Pictures/Wallpapers
echo "✓ Required directories created"

echo ""
echo "Deploying configuration files..."
echo ""

# Deploy Hyprland configs
deploy_config "$CONFIG_DIR/hypr" "$HOME/.config/hypr"

# Deploy Waybar configs
deploy_config "$CONFIG_DIR/waybar" "$HOME/.config/waybar"

# Deploy Mako configs
deploy_config "$CONFIG_DIR/mako" "$HOME/.config/mako"

# Deploy Wlogout configs
deploy_config "$CONFIG_DIR/wlogout" "$HOME/.config/wlogout"

# Deploy Ghostty configs
deploy_config "$CONFIG_DIR/ghostty" "$HOME/.config/ghostty"

# Deploy Fish shell configs
deploy_config "$CONFIG_DIR/fish" "$HOME/.config/fish"

# Deploy Zellij configs
deploy_config "$CONFIG_DIR/zellij" "$HOME/.config/zellij"

# Deploy GTK3 configs
deploy_config "$CONFIG_DIR/gtk-3.0" "$HOME/.config/gtk-3.0"

# Deploy Kanata configs
deploy_config "$CONFIG_DIR/kanata" "$HOME/.config/kanata"

# Deploy Walker configs
deploy_config "$CONFIG_DIR/walker" "$HOME/.config/walker"

# Deploy systemd user services
deploy_config "$CONFIG_DIR/systemd/user" "$HOME/.config/systemd/user"

# Deploy wallpapers
echo "Deploying wallpapers..."
if [ -d "$WALLPAPER_DIR" ]; then
    cp -r "$WALLPAPER_DIR"/* ~/Pictures/Wallpapers/
    echo "✓ Wallpapers deployed to ~/Pictures/Wallpapers/"
else
    echo "⚠ Warning: Wallpapers directory not found"
fi

# Make scripts executable
echo "Making scripts executable..."
if [ -f "$HOME/.config/waybar/system-stats.sh" ]; then
    chmod +x "$HOME/.config/waybar/system-stats.sh"
    echo "✓ Waybar system stats script made executable"
fi

# Deploy SDDM theme configuration
echo "Configuring SDDM theme..."
if [ -f "$CONFIG_DIR/sddm/sddm.conf" ]; then
    sudo cp "$CONFIG_DIR/sddm/sddm.conf" /etc/sddm.conf
    echo "✓ SDDM theme configured (Sugar Candy)"
    
    # Replace Mountain.jpg with dragon.png in SDDM theme
    if [ -f "$HOME/Pictures/Wallpapers/dragon.png" ] && [ -d "/usr/share/sddm/themes/Sugar-Candy/Backgrounds" ]; then
        sudo cp "$HOME/Pictures/Wallpapers/dragon.png" /usr/share/sddm/themes/Sugar-Candy/Backgrounds/
        sudo rm -f /usr/share/sddm/themes/Sugar-Candy/Backgrounds/Mountain.jpg
        sudo mv /usr/share/sddm/themes/Sugar-Candy/Backgrounds/dragon.png /usr/share/sddm/themes/Sugar-Candy/Backgrounds/Mountain.jpg
        echo "✓ Dragon wallpaper set as SDDM background (replaced Mountain.jpg)"
    fi
fi

# Clone Neovim configuration
echo "Setting up Neovim configuration..."
git clone https://github.com/sebastians-codes/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
echo "✓ Neovim configuration cloned from kickstart.nvim"

# Enable and start systemd user services
echo "Enabling systemd user services..."
if [ -f "$HOME/.config/systemd/user/kanata.service" ]; then
    systemctl --user daemon-reload
    systemctl --user enable kanata.service
    systemctl --user start kanata.service
    echo "✓ Kanata systemd service enabled and started"
fi

echo ""
echo "================================="
echo "Configuration deployment complete!"
echo "================================="
echo ""
echo "Optional manual steps:"
echo "1. Review and customize keybindings in ~/.config/hypr/hyprland.conf"
echo "2. Adjust monitor settings in hyprland.conf if needed"
echo ""
echo "Your setup is ready! Reboot and log into Hyprland from SDDM."