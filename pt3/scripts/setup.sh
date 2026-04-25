apt-get update
apt-get install -y curl
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=v5.0.0 bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl && sudo mv kubectl /usr/local/bin/
curl -fsSL https://get.docker.com | sh

sudo usermod -aG docker vagrant
k3d cluster create mycluster --servers 1 --agents 1
kubectl create namespace argocd
kubectl create namespace dev

# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
