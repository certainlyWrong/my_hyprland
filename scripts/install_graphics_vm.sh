#!/bin/bash

# Exit on error
set -e

echo "============================================="
echo "   Setting up VM Graphics (VirtualBox/VMware/QEMU)"
echo "   Note: Hyprland in a VM requires 3D Acceleration!"
echo "============================================="

echo "🎮 Installing generic Mesa drivers for VM support..."
sudo pacman -S --needed --noconfirm \
    mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader

echo "🧰 Installing VM Guest Utilities..."
# Install utilities for the common hypervisors
sudo pacman -S --needed --noconfirm \
    virtualbox-guest-utils-nox \
    open-vm-tools \
    qemu-guest-agent \
    spice-vdagent

echo "⚙️ Enabling VM services..."
# Enable systemd services for guest tools, ignoring errors if we are not in that specific VM type
sudo systemctl enable --now vboxservice.service 2>/dev/null || true
sudo systemctl enable --now vmtoolsd.service 2>/dev/null || true
sudo systemctl enable --now qemu-guest-agent.service 2>/dev/null || true

echo "⚙️ Configuring General Wayland environment..."
# Clean environment setup for VM Wayland, with software fallback
sudo bash -c 'cat <<EOF > /etc/environment
XDG_SESSION_TYPE=wayland
WLR_RENDERER_ALLOW_SOFTWARE=1

# Common Wayland environment variables
QT_QPA_PLATFORM="wayland;xcb"
GDK_BACKEND="wayland,x11"
SDL_VIDEODRIVER=wayland
CLUTTER_BACKEND=wayland
EOF'

echo "⚠️  Important VM Note:"
echo "Hyprland is heavily dependent on actual hardware acceleration."
echo "If you experience crashes or a black screen:"
echo " 1. Ensure you have enabled 3D Acceleration in your hypervisor."
echo " 2. Ensure you have allocated maximum Video Memory."
echo " 3. Consider disabling animations in hyprland.conf (animations { enabled = false })."
echo ""
echo "✅ VM graphics installation complete."
