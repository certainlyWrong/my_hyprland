# My Hyprland Setup 🚀

This repository contains a set of modular and automated scripts for installing and configuring **Hyprland** on Arch Linux. It is designed to be flexible, supporting both bare-metal installations on modern hardware (like hybrid laptops with NVIDIA GPUs) and Virtual Machines.

## 📦 Script Structure

The installation process is divided into modules to make it easier to maintain and adapt to different environments:

### 1. `setup.sh` (The Main Script)
This is the entry point for your installation. Here is what it does:
- Prevents you from running the entire script as `root` (a safety measure for `makepkg`).
- Enables the `[multilib]` repository if needed (essential for 32-bit libraries and Steam).
- Installs base packages and tools (`base-devel`, `git`, audio/video packages).
- **Interactive:** Prompts you to select your environment (Hybrid Laptop or Virtual Machine) and executes the corresponding graphics script.
- Compiles and installs the AUR helper `yay` from scratch.
- Installs the core **Hyprland** packages, Waybar, Kitty, Rofi, and related tools.
- Installs fonts (JetBrains Mono, Nerd Fonts, etc.).
- Calls the secondary script to install the login manager (Ly).
- Enables Pipewire services.

### 2. `install_graphics_hybrid.sh` (For Bare Metal / Dell G15)
This script is triggered when you select the *Hybrid Graphics* option in `setup.sh`. It handles:
- Detecting the running kernel (e.g., `linux`, `linux-lts`) and installing the correct `*-headers` package.
- Installing graphics drivers for Intel + NVIDIA hybrid systems (`nvidia-dkms`, Intel drivers, and Vulkan). *Note: The DKMS driver is recommended for stability on Ampere cards like the RTX 3050.*
- Forcing the local compilation of NVIDIA modules via `dkms autoinstall`.
- Configuring environment variables (`/etc/environment`) required to make NVIDIA play nicely with Wayland (`GBM_BACKEND=nvidia-drm`, fixing invisible cursors, etc.).
- Configuring **Early KMS** by editing `mkinitcpio.conf` and regenerating the initramfs to load drivers at boot.

### 3. `install_graphics_vm.sh` (For Virtual Machines)
This script runs when you select the *Virtual Machine* option. It handles:
- Installing open-source drivers (`mesa`, `vulkan-icd-loader`).
- Installing universal guest utilities for VMs (`virtualbox-guest-utils-nox`, `open-vm-tools`, `qemu-guest-agent`, `spice-vdagent`).
- Enabling system services for these utilities in the background (conditionally ignoring errors depending on your actual hypervisor).
- Configuring basic Wayland environment variables, keeping the environment clean from any NVIDIA driver pollution.
- **Important Warning:** The script reminds you that you MUST enable 3D Acceleration in your hypervisor's settings for Hyprland to run.

### 4. `install_ly.sh` (Login Manager)
Installs the lightweight TUI Display Manager **Ly**, focusing on speed and a text-based interface:
- Installs build dependencies (`zig`, `ncurses`, `pam`, `libxcb`).
- Clones the source code directly from Codeberg.
- Compiles the tool using the Zig build command (`sudo zig build installexe -Dinit_system=systemd`).
- Disables the default TTY prompts to enable Ly's own systemd service.

---

## 🚀 How to Use

1. Clone the repository or navigate to the folder:
   ```bash
   cd ~/Documents/my_hyprland
   ```

2. Ensure the scripts are executable:
   ```bash
   chmod +x setup.sh install_graphics_hybrid.sh install_graphics_vm.sh install_ly.sh
   ```

3. Run the main script (**DO NOT** use `sudo`):
   ```bash
   ./setup.sh
   ```

4. The script will pause to ask for your password interactively only when necessary.
5. At the **Graphics Setup** selection menu, type `1` if you are formatting your hybrid laptop (Dell G15 RTX3050) or `2` if you are testing in a virtual machine.
6. At the end of the script, simply confirm the automatic system reboot!

---

## ⚠️ Troubleshooting & Security Notes

- **Module Not Found in mkinitcpio:** The `install_graphics_hybrid.sh` already handles this by checking your running kernel and downloading the corresponding `headers` package. If the error reappears when updating the kernel in the future, manually run `sudo dkms autoinstall` and then `sudo mkinitcpio -P`.
- **Black screen / Hyprland crash in VM:** Hyprland relies heavily on graphical rendering. Ensure your Virtual Machine settings allocate enough VRAM (Video RAM > 128MB) and that the "Accelerate 3D Graphics" checkbox is enabled in your virtualization engine.
