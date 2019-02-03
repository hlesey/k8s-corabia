#!/usr/bin/env bash

## setup kubelet
cat <<EOF >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
ExecStartPre=/bin/bash -c "if [[ $(/bin/mount | /bin/grep /sys/fs/bpf -c) -eq 0 ]]; then /bin/mount bpffs /sys/fs/bpf -t bpf; fi"
EOF

systemctl daemon-reload
systemctl restart kubelet

kubectl create secret generic -n kube-system cilium-etcd-secrets \
    --from-file=etcd-client-ca.crt=/etc/kubernetes/pki/etcd/ca.crt \
    --from-file=etcd-client.key=/etc/kubernetes/pki/etcd/peer.key \
    --from-file=etcd-client.crt=/etc/kubernetes/pki/etcd/peer.crt

CONTROL_PLANE_IP=$(ip a | grep 192.168 | cut -d ' ' -f 6 | cut -d '/' -f1)
cat "/src/manifests/network/${NETWORK_PLUGIN}/cilium.yaml" | sed -e "s'{{CONTROL_PLANE_IP}}'${CONTROL_PLANE_IP}'g" | kubectl apply -f -
