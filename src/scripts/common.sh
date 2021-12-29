#!/usr/bin/env bash
set -xe

# Setup common configuration for control plane and data plane nodes
# Refs: https://kubernetes.io/docs/setup/independent/install-kubeadm/

# load variables
source /src/scripts/vars.sh
DEBIAN_FRONTEND=noninteractive

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
  while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
    echo 'Waiting for cloud-init...';
    sleep 1;
  done
fi

# install dependencies
apt-get update
apt-get install -y iptables arptables ebtables nfs-kernel-server nfs-common apt-transport-https ntp \
                   telnet jq dos2unix ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# setup ntp
systemctl enable ntp && \
systemctl start ntp

# setup docker
cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
mkdir -p /etc/systemd/system/docker.service.d
systemctl enable docker && \
systemctl restart docker

# add kubernetes repos
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# install kubeadm
sudo apt-get update
apt-get install -y kubeadm="${K8S_VERSION}-00" kubelet="${K8S_VERSION}-00" kubectl="${K8S_VERSION}-00"

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
