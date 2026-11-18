#!/bin/bash
# Installs everything Part 3 needs on a Debian VM: Docker, k3d, kubectl and the Argo CD CLI.
# Unattended and idempotent: tools already present are skipped.
set -euo pipefail

ARCH="$(dpkg --print-architecture)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"

sudo apt-get update
sudo apt-get install -y ca-certificates curl

###############################################################################
# Docker (official repository)
###############################################################################
if ! command -v docker >/dev/null 2>&1; then
    echo "Installing Docker..."
    for pkg in docker.io docker-compose docker-doc podman-docker containerd runc; do
        sudo apt-get remove -y "$pkg" >/dev/null 2>&1 || true
    done

    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: ${ARCH}
Signed-By: /etc/apt/keyrings/docker.asc
EOF
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
fi

###############################################################################
# k3d
###############################################################################
if ! command -v k3d >/dev/null 2>&1; then
    echo "Installing k3d..."
    curl -fsSL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

###############################################################################
# kubectl (k3d does not ship it)
###############################################################################
if ! command -v kubectl >/dev/null 2>&1; then
    echo "Installing kubectl..."
    KVER="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
    curl -fsSLO "https://dl.k8s.io/release/${KVER}/bin/linux/${ARCH}/kubectl"
    curl -fsSLO "https://dl.k8s.io/release/${KVER}/bin/linux/${ARCH}/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
    sudo install -m 0755 kubectl /usr/local/bin/kubectl
fi

###############################################################################
# Argo CD CLI
###############################################################################
if ! command -v argocd >/dev/null 2>&1; then
    echo "Installing argocd CLI..."
    curl -fsSL -o argocd "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-${ARCH}"
    sudo install -m 0555 argocd /usr/local/bin/argocd
fi

echo
docker --version
k3d version
kubectl version --client
argocd version --client --short || true
