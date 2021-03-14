#!/usr/bin/env bash
# Setup data plane node

source /src/scripts/vars.sh
cluster_join=""

while [ "$cluster_join" == "" ] ; do
    echo "waiting for the control-plane node";
    sleep 1;
    cluster_join="$(grep -A2 'kubeadm join' /src/output/.kubeadmin_init | sed 's/\\//g')"
done

$cluster_join 

if [[ "$NETWORK_PLUGIN" == "cilium" ]]; then
## setup kubelet
cat <<EOF >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
ExecStartPre=/bin/bash -c "if [[ $(/bin/mount | /bin/grep /sys/fs/bpf -c) -eq 0 ]]; then /bin/mount bpffs /sys/fs/bpf -t bpf; fi"
EOF
systemctl daemon-reload
systemctl restart kubelet
fi