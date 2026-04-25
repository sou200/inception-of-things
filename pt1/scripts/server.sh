apt-get update
apt-get install -y curl
curl -sfL https://get.k3s.io | sh -
cp /var/lib/rancher/k3s/server/node-token /vagrant/token