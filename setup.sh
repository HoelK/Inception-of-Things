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

	#patch dotven
	sudo sed -i 's/File.exists?/File.exist?/' /home/hkeromne/.vagrant.d/gems/3.3.8/gems/dotenv-0.11.1/lib/dotenv.rb

fi


###############################################################################
# Install Docker
###############################################################################

sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc | cut -f1)

###############################################################################
# Install K3D
###############################################################################

curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install	docker-ce \
					docker-ce-cli \
					containerd.io \
					docker-buildx-plugin \
					docker-compose-plugin

curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd /usr/local/bin/argocd

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
