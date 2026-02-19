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

echo "🎮 Installing graphics drivers (Hybrid Intel + NVIDIA Open)..."
sudo pacman -S --needed --noconfirm \
    mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader \
    vulkan-intel lib32-vulkan-intel intel-media-driver libva-intel-driver \
    nvidia-open nvidia-utils lib32-nvidia-utils nvidia-settings

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

echo "⚙️ Configuring NVIDIA/Hyprland environment..."
# Fix for Hyprland crash and Hybrid GPU issues
sudo bash -c 'cat <<EOF > /etc/environment
# Graphics/Wayland fixes
LIBVA_DRIVER_NAME=nvidia
XDG_SESSION_TYPE=wayland
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
WLR_NO_HARDWARE_CURSORS=1

# Common Wayland environment variables
QT_QPA_PLATFORM="wayland;xcb"
GDK_BACKEND="wayland,x11"
SDL_VIDEODRIVER=wayland
CLUTTER_BACKEND=wayland
EOF'

echo "📝 Configuring Early KMS for NVIDIA..."
# Add NVIDIA modules to mkinitcpio
if ! grep -q "nvidia nvidia_modeset nvidia_uvm nvidia_drm" /etc/mkinitcpio.conf; then
    sudo sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
    sudo mkinitcpio -P
fi

# Set nvidia_drm.modeset=1
if [ ! -f /etc/modprobe.d/nvidia.conf ]; then
    sudo bash -c 'echo "options nvidia-drm modeset=1" > /etc/modprobe.d/nvidia.conf'
fi

echo "✅ Setup complete!"

read -p "🔄 Do you want to reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    reboot
fi
