#!/usr/bin/env bash
# Setup and bootstrap k8s control-plane
set -xe

source /src/scripts/envs.sh

# bootstrap k8s control-plane components
envsubst < /src/manifests/kubeadm/control-plane.yaml > /tmp/control-plane.yaml

kubeadm init --config /tmp/control-plane.yaml > /output/.kubeadmin_init
export KUBECONFIG=/etc/kubernetes/admin.conf

# modify ingress hubble-ui for cilium
sed -i -e "s'hubble-ui.clusterx.qedzone.ro'hubble-ui.${CONTROL_PLANE_PUBLIC_EXTERNAL_DNS}'g" /src/manifests/network/cilium/hubble-ui-ingress.yml

# deploy network cni plugin
kubectl apply -f /src/manifests/network/"${NETWORK_PLUGIN}"

# deploy dashboard
sed -i -e "s'clusterx.qedzone.ro'${CONTROL_PLANE_PUBLIC_EXTERNAL_DNS}'g" /src/manifests/dashboard/dashboard-ingress.yml
kubectl apply -f /src/manifests/dashboard/

# setup cluster-admin sa
kubectl apply -f /src/manifests/cluster-admin/cluster-admin.yaml

# deploy ingress controller
kubectl apply -f  /src/manifests/ingress/"${INGRESS_CONTROLLER}"

# deploy metrics-server
kubectl apply -f /src/manifests/metrics-server/

# scale coredns to 1 replica
kubectl -n kube-system scale deployment coredns --replicas=1

# generate a lifetime admin token
kubectl create token --duration=0s cluster-admin > /output/cluster-admin-token

cp /etc/kubernetes/admin.conf /output/kubeconfig.yaml

# configure root user with kubeconfig
echo "export KUBECONFIG=/output/kubeconfig.yaml"  >> /root/.bashrc

# Enabling shell autocompletion
echo "source <(kubectl completion bash)
. /usr/share/bash-completion/bash_completion
alias kns='kubectl config set-context \$(kubectl config current-context) --namespace'" >>  /root/.bashrc

# finish
ln -s /output/cluster-admin-token /root/cluster-admin-token
echo "-------------------------------------------------------------"
echo "Use this token to login to the kubernetes dashboard:"
cat /root/cluster-admin-token
echo "Enjoy."
