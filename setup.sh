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

echo "� Enabling multilib repository..."
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    sudo bash -c 'cat <<EOF >> /etc/pacman.conf

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF'
    sudo pacman -Syy
fi

echo "�📦 Updating system and installing base dependencies..."
sudo pacman -Syyu --noconfirm
sudo pacman -S --needed --noconfirm base-devel git curl wget zig ncurses pam libxcb

echo "🔍 Detecting running kernel and installing headers..."
KERNEL_TYPE=$(uname -r | sed 's/.*-\([a-z]*\)/\1/')
if [[ "$KERNEL_TYPE" == "arch" ]]; then
    sudo pacman -S --needed --noconfirm linux-headers
elif pacman -Qi "linux-$KERNEL_TYPE-headers" &> /dev/null; then
    sudo pacman -S --needed --noconfirm "linux-$KERNEL_TYPE-headers"
else
    # Fallback to standard headers if detection is ambiguous
    sudo pacman -S --needed --noconfirm linux-headers
fi

echo "============================================="
echo "   Choose your Graphics Setup"
echo "============================================="
echo "1) Hybrid Graphics (Dell G15: Intel + NVIDIA RTX 3050)"
echo "2) Virtual Machine (VirtualBox, VMware, QEMU)"
echo "3) Skip (I already installed graphics drivers)"
read -p "Select an option [1-3]: " GRAPHICS_CHOICE

case $GRAPHICS_CHOICE in
    1)
        ./install_graphics_hybrid.sh
        ;;
    2)
        ./install_graphics_vm.sh
        ;;
    3)
        echo "⏭️ Skipping graphics driver installation."
        ;;
    *)
        echo "❌ Invalid choice. Exiting to avoid broken state."
        exit 1
        ;;
esac


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

echo "🖥️ Installing and configuring Ly Display Manager..."
./install_ly.sh

echo "🔧 Enabling Pipewire services..."
systemctl --user enable pipewire pipewire-pulse wireplumber

# Graphics and Environment setup are now handled in the dedicated driver scripts.

echo "✅ Setup complete!"

read -p "🔄 Do you want to reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    reboot
fi
