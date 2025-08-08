#!/bin/bash

# Hyprland Arch Setup - Package Installation Script
# This script installs all packages needed for your Hyprland setup

set -e

echo "======================================"
echo "Hyprland Arch Setup - Package Install"
echo "======================================"

# Function to check if paru is installed
check_paru() {
    if ! command -v paru &> /dev/null; then
        echo "Installing paru (AUR helper)..."
        git clone https://aur.archlinux.org/paru.git /tmp/paru
        cd /tmp/paru
        makepkg -si --noconfirm
        cd -
    fi
}

# Update system
echo "Updating system packages..."
sudo pacman -Syu --noconfirm

# Install paru if not present
check_paru

# Core system packages
echo "Installing core system packages..."
sudo pacman -S --needed --noconfirm \
    base \
    base-devel \
    sbctl \
    networkmanager \
    iwd \
    bluez \
    bluez-utils \
    pipewire \
    pipewire-alsa \
    pipewire-jack \
    pipewire-pulse \
    wireplumber \
    libpulse \
    gst-plugin-pipewire \
    gst-plugins-base \
    gst-plugins-good \
    gst-plugins-bad \
    gst-plugins-ugly

# Hyprland and Wayland ecosystem
echo "Installing Hyprland and Wayland components..."
sudo pacman -S --needed --noconfirm \
    hyprland \
    hyprpaper \
    hyprlock \
    hypridle \
    hyprpicker \
    xdg-desktop-portal-hyprland \
    waybar \
    mako \
    wl-clipboard \
    grim \
    slurp \
    wlogout \
    wofi \
    walker

# AUR packages
echo "Installing AUR packages..."
paru -S --needed --noconfirm \
    hyprsunset-git \
    grimblast-git \
    wf-recorder-git \
    bluetuith-bin \
    1password \
    zen-browser-bin \
    mullvad-vpn-bin \
    sddm-theme-sugar-candy-git

# Applications and tools
echo "Installing applications and development tools..."
sudo pacman -S --needed --noconfirm \
    ghostty \
    fish \
    neovim \
    git \
    github-cli \
    go \
    go-tools \
    rustup \
    dotnet-sdk \
    npm \
    yazi \
    btop \
    zellij \
    fzf \
    zoxide \
    fastfetch \
    imv \
    discord \
    ffmpeg \
    unzip \
    zip \
    brightnessctl \
    pamixer \
    wiremix \
    impala \
    unclutter \
    ufw \
    power-profiles-daemon \
    sddm

# Fonts
echo "Installing fonts..."
sudo pacman -S --needed --noconfirm \
    noto-fonts \
    noto-fonts-emoji \
    noto-fonts-extra \
    ttf-firacode-nerd \
    ttf-noto-nerd

echo "=================="
echo "Package installation complete!"
echo "=================="

# Enable essential services
echo "Enabling essential services..."
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable sddm
sudo systemctl enable ufw
sudo systemctl enable power-profiles-daemon

echo "Services enabled successfully!"

# Set Fish as default shell
echo "Setting Fish as default shell..."
if command -v fish &> /dev/null; then
    # Add fish to /etc/shells if not already there
    if ! grep -q "/usr/bin/fish" /etc/shells; then
        echo "/usr/bin/fish" | sudo tee -a /etc/shells
    fi
    
    # Change user's default shell to fish
    chsh -s /usr/bin/fish
    echo "✓ Fish shell set as default"
else
    echo "⚠ Warning: Fish not found, skipping shell change"
fi

echo ""
echo "Next steps:"
echo "1. Run the configuration deployment script: ./deploy-configs.sh"
echo "2. Reboot your system"
echo "3. Log into Hyprland from SDDM"