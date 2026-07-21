sudo apt update && sudo apt install curl -y
export INSTALL_K3S_EXEC="agent"
curl -sfL https://get.k3s.io | sh -
