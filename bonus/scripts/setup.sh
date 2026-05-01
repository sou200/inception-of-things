k3d cluster delete mycluster
k3d cluster create mycluster --servers 1 --agents 1 -p "80:80@loadbalancer" -p "443:443@loadbalancer" -p "8888:30001@loadbalancer"

helm repo add gitlab https://charts.gitlab.io/
helm repo update

kubectl create namespace argocd
kubectl create namespace dev
kubectl create namespace gitlab

helm install gitlab gitlab/gitlab \
  -n gitlab \
  -f ../configs/values.yaml

# sleep 5
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
# kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
# kubectl apply -f ../configs/

# password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# echo "Argo CD initial admin password: $password"
