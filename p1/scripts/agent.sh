#!/bin/bash
set -e

sudo apt-get update && sudo apt-get install -y curl net-tools
# K3S_URL and K3S_TOKEN come from the Vagrantfile env and make the installer join as an agent
export INSTALL_K3S_EXEC="agent --node-ip=${AGENT_IP}"
curl -sfL https://get.k3s.io | sh -
