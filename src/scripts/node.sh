#!/usr/bin/env bash
# Setup data plane node

source /src/scripts/envs

# bootstrap k8s worker
envsubst < /src/manifests/kubeadm/worker.yaml > /tmp/worker.yaml
kubeadm join --config /tmp/worker.yaml > /output/.kubeadmin_init

if [[ "$NETWORK_PLUGIN" == "cilium" ]]
then
    ## setup kubelet
    cat <<EOF >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
    ExecStartPre=/bin/bash -c "if [[ $(/bin/mount | /bin/grep /sys/fs/bpf -c) -eq 0 ]]; then /bin/mount bpffs /sys/fs/bpf -t bpf; fi"
EOF
    systemctl daemon-reload
    systemctl restart kubelet
fi
