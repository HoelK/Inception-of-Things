#!/bin/bash
set -e

sudo apt-get update && sudo apt-get install -y curl net-tools
# K3s ships kubectl (symlinked into /usr/local/bin by the installer)
export INSTALL_K3S_EXEC="server --node-ip=${SERVER_IP} --advertise-address=${SERVER_IP} --bind-address=${SERVER_IP}"
curl -sfL https://get.k3s.io | sh -
