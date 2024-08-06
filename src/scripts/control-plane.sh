#!/usr/bin/env bash
# Setup and bootstrap k8s control-plane
set -xe

source /src/scripts/envs.sh

# bootstrap k8s control-plane components
envsubst < /src/manifests/kubeadm/control-plane.yaml > /tmp/control-plane.yaml

kubeadm init --config /tmp/control-plane.yaml > /output/.kubeadmin_init

if [[ $NETWORK_PLUGIN == "cilium" ]]
then
    # modify ingress hubble-ui for cilium
    sed -i -e "s'hubble-ui.clusterx.qedzone.ro'hubble-ui.${CONTROL_PLANE_PUBLIC_EXTERNAL_DNS}'g" /src/manifests/network/cilium/hubble-ui-ingress.yaml

    # deploy network cni plugin
    kubectl apply -f /src/manifests/network/cilium/hubble-ui-ingress.yaml
    helm repo add cilium https://helm.cilium.io/
    helm repo update
    helm upgrade --install cilium cilium/cilium --namespace kube-system --version "${CILIUM_VERSION}" -f /src/manifests/network/cilium/helm-values.yaml
else
    # deploy network cni plugin
    kubectl apply -f /src/manifests/network/"${NETWORK_PLUGIN}"
fi

# scale coredns to 1 replica
kubectl -n kube-system scale deployment coredns --replicas=1

# setup cluster-admin sa
kubectl apply -f /src/manifests/cluster-admin/cluster-admin.yaml

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
