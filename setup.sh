#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Debian Development VM Bootstrap
###############################################################################

USERNAME="$(id -un)"
HOME_DIR="$(getent passwd "$USERNAME" | cut -d: -f6)"

echo "=================================================="
echo "Bootstrapping Debian development environment"
echo "User: $USERNAME"
echo "=================================================="

###############################################################################
# Grant sudo privileges
###############################################################################

if ! sudo -l >/dev/null 2>&1; then
    echo "This script must be run by a user with sudo access."
    exit 1
fi

if [ ! -f "/etc/sudoers.d/90-${USERNAME}" ]; then
    echo "Adding ${USERNAME} to sudoers..."
    echo "${USERNAME} ALL=(ALL:ALL) ALL" | sudo tee "/etc/sudoers.d/90-${USERNAME}" >/dev/null
    sudo chmod 440 "/etc/sudoers.d/90-${USERNAME}"
    sudo visudo -cf "/etc/sudoers.d/90-${USERNAME}"
fi

###############################################################################
# Update system
###############################################################################

echo "Updating system..."

sudo apt update
sudo apt upgrade -y

###############################################################################
# Install packages
###############################################################################

echo "Installing packages..."

sudo apt install -y \
    git \
    neovim \
    curl \
    wget \
    tmux \
    unzip \
    zip \
    htop \
    tree \
    jq \
    ripgrep \
    fd-find \
    build-essential \
    gcc \
    g++ \
    make \
    pkg-config \
    software-properties-common \
    ca-certificates \
    gnupg \
    python3 \
    python3-pip \
    python3-venv \
    openssh-client

###############################################################################
# Install libvirt / KVM
###############################################################################

echo "Installing KVM/libvirt..."

sudo apt install -y \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    virtinst \
    virt-manager \
    bridge-utils \
    dnsmasq-base

sudo systemctl enable libvirtd
sudo systemctl start libvirtd

sudo usermod -aG libvirt "$USERNAME"
sudo usermod -aG kvm "$USERNAME"

###############################################################################
# Install latest Vagrant
###############################################################################

echo "Installing Vagrant..."

VAGRANT_VERSION="2.4.9"

if ! command -v vagrant >/dev/null; then
    cd /tmp

    wget -q \
      "https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_linux_amd64.deb"

    sudo apt install -y "./vagrant_${VAGRANT_VERSION}_linux_amd64.deb"

    rm "vagrant_${VAGRANT_VERSION}_linux_amd64.deb"
fi

###############################################################################
# Install vagrant-libvirt
###############################################################################

if ! vagrant plugin list | grep -q "^vagrant-libvirt "; then
    vagrant plugin install vagrant-libvirt
fi

###############################################################################
# SSH key
###############################################################################

mkdir -p "$HOME_DIR/.ssh"
chmod 700 "$HOME_DIR/.ssh"

if [ ! -f "$HOME_DIR/.ssh/id_ed25519" ]; then
    echo "Generating SSH key..."

    ssh-keygen \
        -t ed25519 \
        -C "${USERNAME}@$(hostname)" \
        -f "$HOME_DIR/.ssh/id_ed25519" \
        -N ""
fi

###############################################################################
# Verify
###############################################################################

echo
echo "=================================================="
echo "Installed version"
echo "=================================================="

vagrant --version

echo
echo "Public SSH key:"
cat "$HOME_DIR/.ssh/id_ed25519.pub"

echo
echo "=================================================="
echo "Bootstrap complete."
echo
echo "Reboot (or log out/in) so your libvirt and kvm group"
echo "memberships take effect."
echo "=================================================="
