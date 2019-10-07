#!/usr/bin/env bash

source /src/scripts/vars.txt

# init the control plane components
kubeadm init --apiserver-advertise-address=$MASTER_IP --pod-network-cidr=10.244.0.0/16 > /src/output/.kubeadmin_init

export KUBECONFIG=/etc/kubernetes/admin.conf

# deploy overlay network
if [[ "$NETWORK_PLUGIN" == "cilium" ]]; then
## setup kubelet
cat <<EOF >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
ExecStartPre=/bin/bash -c "if [[ $(/bin/mount | /bin/grep /sys/fs/bpf -c) -eq 0 ]]; then /bin/mount bpffs /sys/fs/bpf -t bpf; fi"
EOF
systemctl daemon-reload
systemctl restart kubelet

# workaround for 140615704306112:error:2406F079:random number generator:RAND_load_file:Cannot open file:../crypto/rand/randfile.c:88:Filename=/root/.rnd
touch /root/.rnd
touch /home/vagrant/.rnd

kubectl create secret generic -n kube-system cilium-etcd-secrets \
    --from-file=etcd-ca=/etc/kubernetes/pki/etcd/ca.crt \
    --from-file=etcd-client-key=/etc/kubernetes/pki/etcd/peer.key \
    --from-file=etcd-client-crt=/etc/kubernetes/pki/etcd/peer.crt

MASTER_IP=$(ip a | grep 192.168 | cut -d ' ' -f 6 | cut -d '/' -f1)
cat "/src/manifests/network/${NETWORK_PLUGIN}/cilium.yaml" | sed -e "s'{{MASTER_IP}}'${MASTER_IP}'g" | kubectl apply -f -

else
    kubectl apply -f /src/manifests/network/${NETWORK_PLUGIN}
fi

# deploy dashboard
mkdir /home/vagrant/certs
openssl genrsa -out /home/vagrant/certs/dashboard.key 2048
openssl req -x509 -new -nodes -key /home/vagrant/certs/dashboard.key -subj "/CN=k8s.local" -days 3650 -out /home/vagrant/certs/dashboard.crt
kubectl create secret generic kubernetes-dashboard-certs --from-file=tls.crt=/home/vagrant/certs/dashboard.crt --from-file=tls.key=/home/vagrant/certs/dashboard.key --namespace kube-system
kubectl apply -f /src/manifests/dashboard/
kubectl apply -f /src/manifests/rbac/rbac.yaml

# deploy ingress controller
kubectl apply -f  /src/manifests/ingress/${INGRESS_CONTROLLER}

# deploy metrics-server
kubectl apply -f /src/manifests/metrics-server/

# fix coredns
kubectl -n kube-system scale deployment coredns --replicas=1

# get admin token
kubectl describe secret $(kubectl get secrets | grep cluster | cut -d ' ' -f1) | grep token:  | tr -s ' ' | cut -d ' ' -f2 > /src/output/cluster_admin_token.txt
cp /etc/kubernetes/admin.conf /src/output/kubeconfig.yaml

# configure vagrant and root user with kubeconfig
echo "export KUBECONFIG=/src/output/kubeconfig.yaml"  >> /root/.bashrc
echo "export KUBECONFIG=/src/output/kubeconfig.yaml"  >> /home/vagrant/.bashrc

# Enabling shell autocompletion -> FIXME: add them in the image template
echo "source <(kubectl completion bash)" >> /root/.bashrc
echo ". /usr/share/bash-completion/bash_completion" >> /root/.bashrc
echo  "alias kns='kubectl config set-context \$(kubectl config current-context) --namespace'" >>  /root/.bashrc

# set etcdctl parameters
echo "export ETCDCTL_DIAL_TIMEOUT=3s" >> /root/.bashrc
echo "export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt" >> /root/.bashrc
echo "export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/peer.crt" >> /root/.bashrc
echo "export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/peer.key" >> /root/.bashrc
echo "export ETCDCTL_ENDPOINTS=https://127.0.0.1:2379" >> /root/.bashrc
echo "export ETCDCTL_API=3" >> /root/.bashrc

# copy root user bash config to vagrant user
cat /root/.bashrc >> /home/vagrant/.bashrc

# finish
ln -s /src/output/cluster_admin_token.txt /root/cluster_admin_token.txt
echo "-------------------------------------------------------------"
echo "Use this token to login to the kubernetes dashboard:"
cat /root/cluster_admin_token.txt
echo "Enjoi."