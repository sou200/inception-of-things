# k3d cluster create mycluster --servers 1 --agents 1
k3d cluster create mycluster --servers 1 --agents 1
kubectl create namespace argocd
kubectl create namespace dev

kubectl create -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sudo kubectl -n argocd port-forward --address 0.0.0.0 svc/argocd-server 8080:80 &