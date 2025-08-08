#!/bin/bash

# Hyprland Arch Setup - Main Installation Script
# This script orchestrates the complete Hyprland setup installation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "================================================"
echo "Welcome to your Hyprland Arch Setup Installer!"
echo "================================================"
echo ""
echo "This script will install and configure a complete"
echo "Hyprland desktop environment with all your"
echo "customizations and applications."
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please don't run this script as root!"
    echo "   The script will ask for sudo when needed."
    exit 1
fi

# Check if on Arch Linux
if ! command -v pacman &> /dev/null; then
    echo "❌ This script is designed for Arch Linux!"
    echo "   Please run on an Arch-based system."
    exit 1
fi

echo "🔍 Pre-installation checks passed!"
echo ""

# Ask for confirmation
read -p "Do you want to proceed with the installation? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
echo "🚀 Starting installation..."
echo ""

# Step 1: Install packages
echo "============================================"
echo "Step 1/2: Installing packages..."
echo "============================================"
echo ""

if [ -f "$SCRIPT_DIR/scripts/install-packages.sh" ]; then
    chmod +x "$SCRIPT_DIR/scripts/install-packages.sh"
    "$SCRIPT_DIR/scripts/install-packages.sh"
else
    echo "❌ Package installation script not found!"
    exit 1
fi

echo ""
echo "✅ Package installation completed!"
echo ""

# Step 2: Deploy configurations
echo "============================================"
echo "Step 2/2: Deploying configurations..."
echo "============================================"
echo ""

if [ -f "$SCRIPT_DIR/scripts/deploy-configs.sh" ]; then
    chmod +x "$SCRIPT_DIR/scripts/deploy-configs.sh"
    "$SCRIPT_DIR/scripts/deploy-configs.sh"
else
    echo "❌ Configuration deployment script not found!"
    exit 1
fi

echo ""
echo "✅ Configuration deployment completed!"
echo ""

# Final instructions
echo "================================================"
echo "🎉 Installation Complete!"
echo "================================================"
echo ""
echo "Your Hyprland setup has been successfully installed!"
echo ""
echo "📋 What was installed:"
echo "   • Complete Hyprland desktop environment"
echo "   • Waybar status bar with system stats"
echo "   • Mako notification daemon"
echo "   • Wlogout power menu"
echo "   • All your applications and tools"
echo "   • Custom configurations and theming"
echo "   • Wallpapers and fonts"
echo "   • Fish shell set as default"
echo ""
echo "🔄 Next Steps:"
echo "   1. Reboot your system: sudo reboot"
echo "   2. At login screen (SDDM), select 'Hyprland'"
echo "   3. Enjoy your new setup!"
echo ""
echo "🎮 Key Bindings (Super = Windows key):"
echo "   • Super + Return     → Open terminal (Ghostty)"
echo "   • Super + Q          → Close window"  
echo "   • Super + Space      → Application launcher (Walker)"
echo "   • Super + F          → File manager (Yazi)"
echo "   • Super + B          → Web browser (Zen)"
echo "   • Super + D          → Discord"
echo "   • Super + Escape     → Power menu"
echo "   • Print Screen       → Screenshot (area select)"
echo "   • Super + Print      → Full screenshot"
echo ""
echo "Enjoy your new Hyprland setup! 🚀"
