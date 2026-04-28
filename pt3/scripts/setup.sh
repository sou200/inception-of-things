k3d cluster delete mycluster
k3d cluster create mycluster --servers 1 --agents 1 -p "80:80@loadbalancer" -p "443:443@loadbalancer"
kubectl create namespace argocd
kubectl create namespace dev

sleep 5

kubectl create -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl apply -f ../configs/

sleep 5

kubectl patch deployment argocd-repo-server -n argocd \
  --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/env/-","value":{"name":"ARGOCD_GPG_ENABLED","value":"false"}}]'
#kubectl rollout restart deployment -n argocd

password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "Argo CD initial admin password: $password"
