sudo apt update && sudo apt install curl kubectl -y
export INSTALL_K3S_EXEC="server --node-ip=${SERVER_IP} --advertise-address=${SERVER_IP} --bind-address=${SERVER_IP}"
curl -sfL https://get.k3s.io | sh -
