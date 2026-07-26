#!/bin/bash
set -e

sudo apt install iptables curl -y

# Add reliable DNS resolvers (resolvconf-managed system)
echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolvconf/resolv.conf.d/head
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolvconf/resolv.conf.d/head
sudo resolvconf -u

sleep 5
export INSTALL_K3S_EXEC="server --node-ip=${SERVER_IP} --advertise-address=${SERVER_IP} --bind-address=${SERVER_IP}"
curl -sfL https://get.k3s.io | sh -
