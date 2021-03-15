#!/usr/bin/env bash
set -xe

# Setup common configuration for control plane and data plane nodes
# Refs: https://kubernetes.io/docs/setup/independent/install-kubeadm/

# load variables
source /src/scripts/vars.sh

# configure /etc/hosts file

echo "${CONTROL_PLANE_IP} control-plane control-plane.local nfsserver.local
${NODE01_IP}   node01 node01.local
${NODE02_IP}   node02 node02.local" >> /etc/hosts

# configure external DNS, instead of using VBox DNS
echo "DNS=8.8.8.8" >> /etc/systemd/resolved.conf
echo "DNS=8.8.4.4" >> /etc/systemd/resolved.conf
systemctl restart systemd-resolved
sleep 15;

# update system 
export DEBIAN_FRONTEND=noninteractive
systemctl disable apt-daily.timer
systemctl disable apt-daily-upgrade.timer

apt-get update
apt-get install -y iptables arptables ebtables \
                   nfs-kernel-server nfs-common \
                   apt-transport-https ntp docker.io
apt-get install -y curl telnet jq dos2unix

# setup ntp
systemctl enable ntp && \
systemctl start ntp

# setup docker
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
mkdir -p /etc/systemd/system/docker.service.d
systemctl enable docker && \
systemctl start docker

### fix sshd dns lookup
echo "UseDNS no" >> /etc/ssh/sshd_config
systemctl restart sshd

# add kubernetes repos
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# install kubeadm
sudo apt-get update
apt-get install -y kubeadm="${K8S_VERSION}-00" kubelet="${K8S_VERSION}"-00 kubectl="${K8S_VERSION}-00"

# Install kubetail 
curl -s https://raw.githubusercontent.com/johanhaleby/kubetail/control-plane/kubetail --output /usr/local/bin/kubetail
chmod +x /usr/local/bin/kubetail

# fixes
## configure utf-8
cat <<EOF > /etc/environment
LANG=en_US.utf-8
LC_ALL=en_US.utf-8
EOF

## config vim
cat <<EOF >/root/.vimrc
syntax on
filetype on
set incsearch
set ignorecase
set number
set tabstop=2 smarttab expandtab
set shiftwidth=2
EOF

# Enabling shell autocompletion
echo "source <(kubectl completion bash)
. /usr/share/bash-completion/bash_completion
alias kns='kubectl config set-context \$(kubectl config current-context) --namespace'" >>  /root/.bashrc
