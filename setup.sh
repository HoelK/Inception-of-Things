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
    make \
    pkg-config \
    gnupg \
    python3 \
    python3-pip \
    python3-venv \

###############################################################################
# Install libvirt / KVM
###############################################################################

echo "Installing KVM/libvirt..."

sudo apt install -y \
    libvirt-dev \
    ruby-dev \
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

VAGRANT_VERSION="2.4.9"

cd /tmp

wget "https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}-1_amd64.deb"

sudo apt install -y "./vagrant_${VAGRANT_VERSION}-1_amd64.deb"

rm "vagrant_${VAGRANT_VERSION}-1_amd64.deb"


###############################################################################
# Install vagrant-libvirt
###############################################################################

if ! vagrant plugin list | grep -q "^vagrant-libvirt "; then
    vagrant plugin install vagrant-libvirt vagrant-env dotenv

	#patch dotven
	sudo sed -i 's/File.exists?/File.exist?/' /home/hkeromne/.vagrant.d/gems/3.3.8/gems/dotenv-0.11.1/lib/dotenv.rb

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
echo "=================================================="
echo "Bootstrap complete."
echo
echo "Reboot (or log out/in) so your libvirt and kvm group"
echo "memberships take effect."
echo "=================================================="
