apt-get update
apt-get install -y curl
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --config /vagrant/config/config_server.yaml" sh -