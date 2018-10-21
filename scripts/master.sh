#!/usr/bin/env bash

export PATH=$PATH:/root/go/bin/
kubeadm init --apiserver-advertise-address=192.168.100.100 --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=cri > /scripts/.kubeadmin_init

export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl apply -f /scripts/flannel/kube-flannel.yml
kubectl apply -f /scripts/rbac/rbac.yaml

#install dashboard
mkdir /home/vagrant/certs
openssl genrsa -out /home/vagrant/certs/dashboard.key 2048
openssl req -x509 -new -nodes -key /home/vagrant/certs/dashboard.key -subj "/CN=k8s.local" -days 3650 -out /home/vagrant/certs/dashboard.crt
kubectl create secret generic kubernetes-dashboard-certs --from-file=tls.crt=/home/vagrant/certs/dashboard.crt --from-file=tls.key=/home/vagrant/certs/dashboard.key --namespace kube-system
kubectl apply -f /scripts/dashboard/

# install nginx-ingress
kubectl apply -f /scripts/ingress-controller/namespace.yaml
kubectl apply -f  /scripts/ingress-controller/

# deploy debug container
kubectl apply -f /scripts/debug_container/deployment.yaml

# deploy metrics-server
kubectl apply -f /scripts/metrics-server/

# get admin token
kubectl describe secret $(kubectl get secrets | grep cluster | cut -d ' ' -f1) | grep token:  | tr -s ' ' | cut -d ' ' -f2 > /scripts/cluster_admin_token.txt

# configure vagrant and root user with kubeconfig
echo "export KUBECONFIG=/etc/kubernetes/admin.conf"  >> /root/.bashrc
setfacl -m u:vagrant:rx /etc/kubernetes/admin.conf
echo "export KUBECONFIG=/etc/kubernetes/admin.conf"  >> /home/vagrant/.bashrc

# configure shortcuts
echo "alias set_default_namespace='/scripts/set_default_namespace.sh'" >> /root/.bashrc
echo "alias set_default_namespace='/scripts/set_default_namespace.sh'" >> /home/vagrant/.bashrc

ln -s /scripts/cluster_admin_token.txt /root/cluster_admin_token.txt
echo "-------------------------------------------------------------"
echo "Use this token to login to the kubernetes dashboard:"
cat /root/cluster_admin_token.txt
echo "Enjoi."