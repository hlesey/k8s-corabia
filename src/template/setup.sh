#!/usr/bin/env bash

# https://kubernetes.io/docs/setup/independent/install-kubeadm/
K8S_VERSION="1.14.1"

############################### INITIAL SETUP ###############################
# update system 
apt-get update && apt-get upgrade -y
apt-get install -y apt-transport-https curl telnet 

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


############################### KERNEL UPGRADE ###############################
# needed for cilium bpf
# KERNEL="v4.19.25"
# KERNEL_LONG="4.19.25-041925"
# KERNEL_DATE="201902230535"

# wget http://kernel.ubuntu.com/~kernel-ppa/mainline/${KERNEL}/linux-headers-${KERNEL_LONG}_${KERNEL_LONG}.${KERNEL_DATE}_all.deb
# wget http://kernel.ubuntu.com/~kernel-ppa/mainline/${KERNEL}/linux-headers-${KERNEL_LONG}-generic_${KERNEL_LONG}.${KERNEL_DATE}_amd64.deb
# wget http://kernel.ubuntu.com/~kernel-ppa/mainline/${KERNEL}/linux-image-unsigned-${KERNEL_LONG}-generic_${KERNEL_LONG}.${KERNEL_DATE}_amd64.deb
# wget http://kernel.ubuntu.com/~kernel-ppa/mainline/${KERNEL}/linux-modules-${KERNEL_LONG}-generic_${KERNEL_LONG}.${KERNEL_DATE}_amd64.deb

# dpkg -i *.deb
# rm -rf *.deb


############################### PREPARE KUBEADM ###############################
kubeadm config images pull