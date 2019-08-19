#!/usr/bin/env bash

# https://kubernetes.io/docs/setup/independent/install-kubeadm/
K8S_VERSION="1.15.1"
ETCD_VERSION=${ETCD_VERSION:-v3.3.10}

############################### INITIAL SETUP ###############################
# update system 
export DEBIAN_FRONTEND=noninteractive
systemctl disable apt-daily.timer and systemctl disable apt-daily-upgrade.timer
apt-get update && apt-get upgrade -y
apt-get install -y apt-transport-https curl telnet jq
apt-get install -yq nfs-kernel-server nfs-common

# add kubernetes repos
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# install docker
apt-get update
apt-get install -y docker.io
systemctl enable docker

# install kubeadm
apt-get install -y kubeadm=${K8S_VERSION}-00 kubelet=${K8S_VERSION}-00 kubectl=${K8S_VERSION}-00

# Install kubetail 
curl -s https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail --output /usr/local/bin/kubetail
chmod +x /usr/local/bin/kubetail

# install etcdctl 
curl -L https://github.com/coreos/etcd/releases/download/$ETCD_VERSION/etcd-$ETCD_VERSION-linux-amd64.tar.gz -o etcd-$ETCD_VERSION-linux-amd64.tar.gz
tar xzvf etcd-$ETCD_VERSION-linux-amd64.tar.gz
cp etcd-$ETCD_VERSION-linux-amd64/etcdctl /usr/local/bin/
rm -rf etcd-*
etcdctl version

# install auger
git clone https://github.com/jpbetz/auger
cd auger
make release
cp build/auger /usr/local/bin/
cd ..

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

############################### PRE-PULL DOCKER IMAGES  ###############################
# kube-system images
kubeadm config images pull
docker pull quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.24.1
docker pull k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1
docker pull k8s.gcr.io/metrics-server-amd64:v0.3.2
docker pull docker.io/cilium/cilium-init:2018-10-16
docker pull docker.io/cilium/cilium:v1.4.2
docker pull docker.io/cilium/operator:v1.4.2

# other usefull images
docker pull hlesey/toolbox:1.0
docker pull nginx