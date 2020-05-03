#!/usr/bin/env bash

# https://kubernetes.io/docs/setup/independent/install-kubeadm/
K8S_VERSION="1.18.2"
ETCD_VERSION=${ETCD_VERSION:-v3.3.10}

############################### INITIAL SETUP ###############################
# update system 
export DEBIAN_FRONTEND=noninteractive
systemctl disable apt-daily.timer and systemctl disable apt-daily-upgrade.timer
apt-get update && apt-get upgrade -y
sudo apt-get install -y iptables arptables ebtables
apt-get install -y nfs-kernel-server nfs-common
apt-get install -y ntp 
apt-get install -y apt-transport-https curl telnet jq dos2unix

# switch to legacy versions
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
sudo update-alternatives --set arptables /usr/sbin/arptables-legacy
sudo update-alternatives --set ebtables /usr/sbin/ebtables-legacy

# add kubernetes repos
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# setup ntp
systemctl enable ntp

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

# FIXME: configure sshd to not check dns


############################### PRE-PULL DOCKER IMAGES  ###############################

# kube-system images
kubeadm config images pull

## grep -Rni 'image:' src/manifests/ | cut -d ':' -f4,5 | sort -u  | sed 's/"//g' | sort -u
docker pull docker.io/cilium/cilium:v1.6.8
docker pull docker.io/cilium/operator:v1.6.8
docker pull hlesey/toolbox:1.0
docker pull k8s.gcr.io/metrics-server-amd64:v0.3.6
docker pull kubernetesui/dashboard:v2.0.0
docker pull kubernetesui/metrics-scraper:v1.0.4
docker pull quay.io/coreos/flannel:v0.12.0-amd64
docker pull quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.32.0
