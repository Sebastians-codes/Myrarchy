# Hyprland Arch Setup

A complete Hyprland desktop environment setup for Arch Linux with all configurations and applications.

## 🚀 Quick Start

```bash
git clone https://github.com/Sebastians-codes/Myrarchy hyprland-setup
cd hyprland-setup
./setup.sh
```

## 📋 What's Included

### Desktop Environment
- **Hyprland** - Dynamic tiling Wayland compositor
- **Waybar** - Status bar with system stats
- **Mako** - Notification daemon
- **Wlogout** - Power menu
- **Hyprpaper** - Wallpaper daemon
- **Hypridle** - Idle management
- **Hyprlock** - Screen locker

### Applications
- **Ghostty** - Terminal emulator
- **Fish** - Shell (set as default)
- **Walker** - Application launcher
- **Yazi** - File manager
- **Zen Browser** - Web browser
- **Discord** - Chat
- **Neovim** - Text editor
- **Zellij** - Terminal multiplexer
- **Btop** - System monitor

### Development Tools
- Git & GitHub CLI
- Go & Go tools
- Rust (rustup)
- .NET SDK
- Node.js & NPM

## 🖥️ Hardware Requirements

This setup is hardware-agnostic. You'll need to install appropriate drivers:

### GPU Drivers
- **NVIDIA**: `nvidia nvidia-utils`
- **AMD**: `mesa vulkan-radeon`
- **Intel**: `mesa vulkan-intel`

### CPU Microcode
- **Intel**: `intel-ucode`
- **AMD**: `amd-ucode`

## 🎮 Key Bindings

| Key Combination | Action |
|----------------|--------|
| `Super + Return` | Open terminal |
| `Super + Q` | Close window |
| `Super + Space` | Application launcher |
| `Super + F` | File manager |
| `Super + B` | Web browser |
| `Super + D` | Discord |
| `Super + Escape` | Power menu |
| `Print Screen` | Screenshot (area) |
| `Super + Print` | Full screenshot |
| `Super + H/J/K/L` | Move focus |
| `Super + Shift + H/J/K/L` | Move windows |
| `Super + 1-9` | Switch workspace |
| `Super + Shift + 1-9` | Move to workspace |

## 📁 Directory Structure

```
hyprland-setup/
├── setup.sh              # Main installation script
├── scripts/
│   ├── install-packages.sh    # Package installation
│   └── deploy-configs.sh      # Configuration deployment
├── configs/
│   ├── hypr/             # Hyprland configurations
│   ├── waybar/           # Status bar config
│   ├── mako/             # Notifications
│   ├── wlogout/          # Power menu
│   ├── ghostty/          # Terminal config
│   ├── fish/             # Shell config
│   ├── zellij/           # Terminal multiplexer
│   └── gtk-3.0/          # GTK theming
└── wallpapers/           # Desktop wallpapers
```

## 🔧 Manual Setup Required

### Prerequisites
1. Fresh Arch Linux installation
2. Working internet connection
3. User with sudo privileges

### After Installation
1. Install your GPU drivers
2. Install CPU microcode
3. Reboot system
4. Select "Hyprland" at login screen

## 🎨 Theme

- **Colors**: Vague theme with muted pastels
- **Font**: JetBrains Mono Nerd Font
- **Cursor**: Default with 2-second timeout
- **Border**: Pink accent with rounded corners

## 📸 Screenshots

Screenshots are saved to `~/Pictures/Screenshots/` with timestamps.

## 🔒 Security Features

- UFW firewall (enabled)
- Secure Boot ready (sbctl included)
- Screen lock after 10 minutes idle
- Suspend after 20 minutes idle

## 🐛 Troubleshooting

### Common Issues
1. **No audio**: Restart pipewire services
2. **No wallpaper**: Check `~/Pictures/Wallpapers/dragon.png` exists
3. **Display issues**: Update monitor settings in `~/.config/hypr/hyprland.conf`

### Logs
- Hyprland: `journalctl --user -u hyprland`
- Audio: `journalctl --user -u pipewire`

## 🤝 Contributing

This setup is personalized but feel free to adapt it for your needs.

## 📄 License

Personal configuration - use at your own discretion.
