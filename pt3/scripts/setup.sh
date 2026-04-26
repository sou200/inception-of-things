# k3d cluster create mycluster --servers 1 --agents 1
k3d cluster create mycluster --servers 1 --agents 1
kubectl create namespace argocd
kubectl create namespace dev

kubectl create -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sleep 5
sudo kubectl -n argocd port-forward --address 0.0.0.0 svc/argocd-server 8080:80 &

password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "Argo CD initial admin password: $password"