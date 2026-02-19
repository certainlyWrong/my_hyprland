
echo "🚀 Updating system..."
sudo pacman -Syyu

echo "Installing packages..."
sudo pacman -S git curl nano pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber gstreamer gst-libav gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly ffmpeg

echo "Installing yay..."
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

cd && rm -rf yay/

echo "Installing hyprland and dependencies..."
sudo pacman -S hyprland hyprpaper hyprlock hypridle hyprcursor hyprpicker hyprshare waybar kitty rofi-wayland dolphin dolphin-plugins ark kio-admin polkit-kde-agent qt5-wayland qt6-wayland xdg-user-dirs-gtk xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk dunst cliphist vlc pavucontrol-qt

echo "Installing fonts..."
sudo pacman -S ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-fira-code ttf-font-awesome ttf-opensans noto-fonts ttf-droid ttf-roboto

echo "Installing yay..."
yay -S --noconfirm hyprshot wlogout qview visual-studio-code-bin google-chrome

systemctl --user enable pipewire pipewire-pulse wireplumber

systemctl --user start pipewire pipewire-pulse wireplumber

shutdown -r now
