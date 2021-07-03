#!/usr/bin/env bash
# Setup and bootstrap k8s control-plane
set -xe

source /src/scripts/vars.sh

# bootstrap k8s control-plane components
sed -e "s'{{CONTROL_PLANE_IP}}'${CONTROL_PLANE_IP}'g" /src/manifests/kubeadm/control-plane.yaml | \
sed -e "s'{{CONTROL_PLANE_PUBLIC_DNS}}'${CONTROL_PLANE_PUBLIC_DNS}'g" | \
sed -e "s'{{CONTROL_PLANE_PUBLIC_EXTERNAL_DNS}}'${CONTROL_PLANE_PUBLIC_EXTERNAL_DNS}'g" > /tmp/control-plane.yaml

kubeadm init --config /tmp/control-plane.yaml > /src/output/.kubeadmin_init

export KUBECONFIG=/etc/kubernetes/admin.conf

# deploy overlay network
if [[ "$NETWORK_PLUGIN" == "cilium" ]]; then
    # enable bpf and setup kubelet
    cat <<EOF >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
    ExecStartPre=/bin/bash -c "if [[ $(/bin/mount | /bin/grep /sys/fs/bpf -c) -eq 0 ]]; then /bin/mount bpffs /sys/fs/bpf -t bpf; fi"
EOF
    systemctl daemon-reload
    systemctl restart kubelet

    sed -i -e "s'hubble-ui.clusterx.qedzone.ro'hubble-ui.${CONTROL_PLANE_PUBLIC_EXTERNAL_DNS}'g" /src/manifests/network/cilium/hubble-ui-ingress.yml
fi


kubectl apply -f /src/manifests/network/"${NETWORK_PLUGIN}"

# deploy dashboard
sed -i -e "s'clusterx.qedzone.ro'${CONTROL_PLANE_PUBLIC_EXTERNAL_DNS}'g" /src/manifests/dashboard/dashboard-ingress.yaml
kubectl apply -f /src/manifests/dashboard/

# setup cluster-admin sa
kubectl apply -f /src/manifests/rbac/rbac.yaml

# deploy ingress controller
kubectl apply -f  /src/manifests/ingress/"${INGRESS_CONTROLLER}"

# deploy metrics-server
kubectl apply -f /src/manifests/metrics-server/

# scale coredns to 1 replica
kubectl -n kube-system scale deployment coredns --replicas=1

# get admin token
kubectl describe secret "$(kubectl get secrets | grep cluster | cut -d ' ' -f1)" | grep token:  | tr -s ' ' | cut -d ' ' -f2 > /src/output/cluster-admin-token
cp /etc/kubernetes/admin.conf /src/output/kubeconfig.yaml

# configure vagrant and root user with kubeconfig
echo "export KUBECONFIG=/src/output/kubeconfig.yaml"  >> /root/.bashrc

# Enabling shell autocompletion
echo "source <(kubectl completion bash)
. /usr/share/bash-completion/bash_completion
alias kns='kubectl config set-context \$(kubectl config current-context) --namespace'" >>  /root/.bashrc

# finish
ln -s /src/output/cluster-admin-token /root/cluster-admin-token
echo "-------------------------------------------------------------"
echo "Use this token to login to the kubernetes dashboard:"
cat /root/cluster-admin-token
echo "Enjoy."
