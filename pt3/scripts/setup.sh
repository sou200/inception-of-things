# k3d cluster create mycluster --servers 1 --agents 1
k3d cluster create mycluster --servers 1 --agents 1 \
  -p "80:80@loadbalancer" \
  -p "443:443@loadbalancer"
kubectl create namespace argocd
kubectl create namespace dev

kubectl create -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
