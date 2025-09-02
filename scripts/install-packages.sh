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
        echo "Installing rustup and configuring Rust toolchain..."
        sudo pacman -S --needed --noconfirm rustup
        rustup default stable
        
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

# Install all packages using paru (handles both official repos and AUR)
echo "Installing all packages with paru..."
paru -S --needed --noconfirm \
    base \
    base-devel \
    sbctl \
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
    gst-plugins-ugly \
    hyprland \
    hyprpaper \
    hyprlock \
    hypridle \
    hyprpicker \
    xdg-desktop-portal-hyprland \
    waybar \
    dunst \
    wl-clipboard \
    grim \
    slurp \
    wlogout \
    walker-bin \
    hyprsunset \
    grimblast-git \
    wf-recorder-git \
    bluetuith-bin \
    1password \
    zen-browser-bin \
    mullvad-vpn-bin \
    sddm-theme-sugar-candy-git \
    ghostty \
    fish \
    neovim \
    git \
    github-cli \
    go \
    go-tools \
    dotnet-sdk \
    npm \
    yazi \
    btop \
    zellij \
    fzf \
    zoxide \
    imv \
    discord \
    ffmpeg \
    unzip \
    zip \
    brightnessctl \
    pamixer \
    wiremix \
    impala \
    ufw \
    power-profiles-daemon \
    sddm \
    noto-fonts \
    noto-fonts-emoji \
    noto-fonts-extra \
    ttf-firacode-nerd \
    ttf-noto-nerd \
    cloc \
    codespell \
    samba \
    xh \
    zram-generator \
    wireguard-tools \
    eza \
    fd \
    cheat \
    posting \
    gitui

echo "=================="
echo "Package installation complete!"
echo "=================="

# Enable essential services
echo "Enabling essential services..."
sudo systemctl enable iwd
sudo systemctl enable bluetooth
sudo systemctl enable sddm
sudo systemctl enable ufw
sudo systemctl enable power-profiles-daemon

# Enable UFW firewall
echo "Enabling UFW firewall..."
sudo ufw --force enable
echo "✓ UFW firewall enabled"

echo "Services enabled successfully!"

# Install kanata via cargo
echo "Installing kanata via cargo..."
if command -v cargo &> /dev/null; then
    cargo install kanata --locked
    echo "✓ Kanata installed via cargo"
else
    echo "Installing Rust and cargo first..."
    rustup default stable
    cargo install kanata --locked
    echo "✓ Kanata installed via cargo"
fi

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
