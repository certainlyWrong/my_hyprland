#!/bin/bash

# Exit on error
set -e

echo "🖥️ Installing and configuring Ly (Display Manager) from source..."

# Prevention: Check for dependencies
for pkg in zig ncurses pam libxcb; do
    if ! pacman -Qs "$pkg" > /dev/null; then
        echo "📦 Installing missing dependency: $pkg"
        sudo pacman -S --needed --noconfirm "$pkg"
    fi
done

TEMP_LY=$(mktemp -d)
git clone https://codeberg.org/fairyglade/ly "$TEMP_LY"
cd "$TEMP_LY"

echo "🔨 Building Ly..."
# Using zig build installexe as recently adjusted by user
sudo zig build installexe -Dinit_system=systemd

echo "⚙️ Configuring services..."
sudo systemctl enable ly@tty2.service
sudo systemctl disable getty@tty2.service

cd -
rm -rf "$TEMP_LY"

echo "✅ Ly installation complete!"
