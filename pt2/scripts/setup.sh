
cd /vagrant/config
kubectl apply -f app1.yaml \
    -f app2.yaml -f app3.yaml \
    -f ingress.yaml