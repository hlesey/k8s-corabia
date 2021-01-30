#!/usr/bin/env bash
# Deploy cilium on k8s cluster and enable bpf 

## setup kubelet
cat <<EOF >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
ExecStartPre=/bin/bash -c "if [[ $(/bin/mount | /bin/grep /sys/fs/bpf -c) -eq 0 ]]; then /bin/mount bpffs /sys/fs/bpf -t bpf; fi"
EOF

systemctl daemon-reload
systemctl restart kubelet
