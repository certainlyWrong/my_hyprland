#!/bin/bash

# Exit on error
set -e

echo "============================================="
echo "   Setting up Hybrid Graphics (Intel + NVIDIA) "
echo "   Target: Dell G15 5530 (i5-13450HX + RTX 3050)"
echo "============================================="

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

echo "🎮 Installing graphics drivers (Hybrid Intel + NVIDIA DKMS)..."
sudo pacman -S --needed --noconfirm \
    mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader \
    vulkan-intel lib32-vulkan-intel intel-media-driver libva-intel-driver \
    nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings

echo "⚙️ Configuring NVIDIA/Hyprland environment..."
# Fix for Hyprland crash and Hybrid GPU issues
sudo bash -c 'cat <<EOF > /etc/environment
# Graphics/Wayland fixes
LIBVA_DRIVER_NAME=nvidia
XDG_SESSION_TYPE=wayland
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
NVD_BACKEND=direct

# Common Wayland environment variables
QT_QPA_PLATFORM="wayland;xcb"
GDK_BACKEND="wayland,x11"
SDL_VIDEODRIVER=wayland
CLUTTER_BACKEND=wayland
EOF'

echo "⚠️  NOTE: We recommend adding 'cursor { no_hardware_cursors = true }' to your hyprland.conf instead of using WLR_NO_HARDWARE_CURSORS."

echo "📝 Configuring Early KMS for NVIDIA..."
# Add NVIDIA modules to mkinitcpio if not present
if ! grep -q "nvidia nvidia_modeset nvidia_uvm nvidia_drm" /etc/mkinitcpio.conf; then
    sudo sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
fi
# Force DKMS build before mkinitcpio
echo "🔨 Building NVIDIA kernel modules via DKMS..."
sudo dkms autoinstall

# Always regenerate to be safe after driver/header changes
sudo mkinitcpio -P

# Set nvidia_drm.modeset=1
if [ ! -f /etc/modprobe.d/nvidia.conf ]; then
    sudo bash -c 'echo "options nvidia-drm modeset=1" > /etc/modprobe.d/nvidia.conf'
fi

echo "✅ Hybrid graphics installation complete."
