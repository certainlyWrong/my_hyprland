#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting setup script..."

# Prevention: Do NOT run as root/sudo directly
if [[ $EUID -eq 0 ]]; then
   echo "❌ Please DO NOT run this script with sudo."
   echo "The script will ask for your password when needed."
   exit 1
fi

echo "📦 Updating system and installing base dependencies..."
sudo pacman -Syyu --noconfirm
sudo pacman -S --needed --noconfirm base-devel git curl wget zig ncurses pam libxcb

# Function to install yay
install_yay() {
    if ! command -v yay &> /dev/null; then
        echo "✨ Installing yay..."
        TEMP_DIR=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$TEMP_DIR"
        cd "$TEMP_DIR"
        makepkg -si --noconfirm
        cd -
        rm -rf "$TEMP_DIR"
    else
        echo "✅ yay is already installed."
    fi
}

install_yay

echo "🎨 Installing Hyprland and desktop components..."
sudo pacman -S --needed --noconfirm \
    hyprland hyprpaper hyprlock hypridle hyprcursor hyprpicker \
    waybar kitty rofi-wayland dolphin dolphin-plugins ark kio-admin \
    polkit-kde-agent qt5-wayland qt6-wayland xdg-user-dirs-gtk \
    xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    dunst cliphist vlc pavucontrol-qt \
    pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber \
    gstreamer gst-libav gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly ffmpeg

echo "🔡 Installing fonts..."
sudo pacman -S --needed --noconfirm \
    ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-fira-code \
    ttf-font-awesome ttf-opensans noto-fonts ttf-droid ttf-roboto

echo "🛠️ Installing AUR packages..."
yay -S --noconfirm hyprshot wlogout qview visual-studio-code-bin google-chrome

echo "🖥️ Installing and configuring Ly (Display Manager) from source..."
TEMP_LY=$(mktemp -d)
git clone --recurse-submodules https://codeberg.org/fairyglade/ly "$TEMP_LY"
cd "$TEMP_LY"
# Using the specific command requested by the user, now with sudo to avoid AccessDenied
sudo zig build installexe -Dinit_system=systemd
# Manually installing since installexe usually just builds it in zig-out
sudo ./zig-out/bin/ly-setup install
cd -
rm -rf "$TEMP_LY"

sudo systemctl enable ly.service

echo "🔧 Enabling Pipewire services..."
systemctl --user enable pipewire pipewire-pulse wireplumber

echo "✅ Setup complete!"

read -p "🔄 Do you want to reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    reboot
fi
