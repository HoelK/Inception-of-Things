#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Debian Development VM Bootstrap
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
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
	rsync \
    ripgrep \
    fd-find \
    build-essential \
    make \
    pkg-config \
    gnupg \
    python3 \
    python3-pip \
    python3-venv \
	ca-certificates \

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

	# patch dotenv (File.exists? was removed in Ruby 3.2)
	find "$HOME_DIR/.vagrant.d/gems" -path '*/gems/dotenv-*/lib/dotenv.rb' \
		-exec sed -i 's/File.exists?/File.exist?/' {} +

fi


###############################################################################
# Part 3 tooling: Docker, k3d, kubectl, Argo CD CLI
###############################################################################

"$SCRIPT_DIR/p3/scripts/install.sh"

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
