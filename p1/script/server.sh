sudo apt update && sudo apt install curl -y
export INSTALL_K3S_EXEC="server"
curl -sfL https://get.k3s.io | sh -
