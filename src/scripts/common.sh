#!/usr/bin/env bash
set -xe

# Setup common configuration for control plane and data plane nodes
# Refs: https://kubernetes.io/docs/setup/independent/install-kubeadm/

# load variables
source /src/scripts/envs.sh
export DEBIAN_FRONTEND=noninteractive

# add control-plane IP to hosts file
echo "${CONTROL_PLANE_IP} control-plane control-plane.local nfsserver.local" >> /etc/hosts

# VirtualBox specific
if [[ "$(dmidecode -s system-manufacturer)" == "innotek GmbH" ]]; then
  # use external DNS, instead of local VBox
  echo "DNS=8.8.8.8" >> /etc/systemd/resolved.conf
  echo "DNS=8.8.4.4" >> /etc/systemd/resolved.conf
  systemctl restart systemd-resolved

  # disable sshd dns lookup
  echo "UseDNS no" >> /etc/ssh/sshd_config
  systemctl restart sshd

  # add nodes IPs to hosts file
  echo "${NODE01_IP} node01 node01.local" >> /etc/hosts
  echo "${NODE02_IP} node02 node02.local" >> /etc/hosts
fi

# AWS specific
if [[ "$(dmidecode -s system-manufacturer)" == "Amazon EC2" ]]; then
    echo 'Waiting for cloud-init...';
    while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
        sleep 1;
    done
fi

# install dependencies
apt-get update > /dev/null
yes | apt-get install -yq iptables arptables ebtables nfs-kernel-server nfs-common apt-transport-https ntp \
                   telnet jq dos2unix ca-certificates curl gnupg lsb-release gpg software-properties-common > /dev/null

# install cri-o
# https://github.com/cri-o/packaging/blob/main/README.md#distributions-using-deb-packages

## Add the Kubernetes repository
curl -fsSL https://pkgs.k8s.io/core:/stable:/v"${K8S_VERSION}"/deb/Release.key | gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/ /" > /etc/apt/sources.list.d/kubernetes.list


# Add the CRI-O repository
curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/stable:/v"${CRIO_VERSION}"/deb/Release.key | gpg --dearmor --yes -o /etc/apt/keyrings/cri-o-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/stable:/v${CRIO_VERSION}/deb/ /" > /etc/apt/sources.list.d/cri-o.list

apt-get update > /dev/null
yes | apt-get install -yq cri-o cri-tools > /dev/null

# setup cri-o
systemctl daemon-reload
systemctl enable crio
systemctl start crio

# install kubelet, kubeadm, kubectl
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

apt-get update > /dev/null
yes | apt-get install -yq \
    kubeadm="${K8S_VERSION}.${K8S_PATCH_VERSION}-*" \
    kubelet="${K8S_VERSION}.${K8S_PATCH_VERSION}-*" \
    kubectl="${K8S_VERSION}.${K8S_PATCH_VERSION}-*" \
    > /dev/null

# Install Helm
curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor --yes -o  /usr/share/keyrings/helm.gpg
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" > /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update  > /dev/null
yes | apt-get install helm  > /dev/null


# Install kubetail
curl -s https://raw.githubusercontent.com/johanhaleby/kubetail/control-plane/kubetail --output /usr/local/bin/kubetail
chmod +x /usr/local/bin/kubetail

# update system
systemctl disable apt-daily.timer
systemctl disable apt-daily-upgrade.timer

# configure utf-8
cat <<EOF > /etc/environment
LANG=en_US.utf-8
LC_ALL=en_US.utf-8
EOF

# Install and configure k8s prerequisites
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#install-and-configure-prerequisites
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sysctl --system
