#!/usr/bin/env bash

# https://kubernetes.io/docs/setup/independent/install-kubeadm/

K8S_VERSION="1.13.2"

############################### INITIAL SETUP ###############################

apt-get update && apt-get upgrade -y
apt-get install -y apt-transport-https curl telnet 

# setup vim
cat <<EOF >/root/.vimrc
syntax on
filetype on
set incsearch
set ignorecase
set number
set tabstop=2 smarttab expandtab
set shiftwidth=2
EOF

# add kubernetes repos
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# install docker
apt-get update
apt-get install -y docker.io

# install kubeadm
apt-get install -y kubeadm=${K8S_VERSION}-00 kubelet=${K8S_VERSION}-00 kubectl=${K8S_VERSION}-00

# other
cat <<EOF > /etc/environment
LANG=en_US.utf-8
LC_ALL=en_US.utf-8
EOF

# SETUP KERNEL 4.8
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.8/linux-headers-4.8.0-040800-generic_4.8.0-040800.201610022031_amd64.deb
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.8/linux-headers-4.8.0-040800_4.8.0-040800.201610022031_all.deb
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.8/linux-image-4.8.0-040800-generic_4.8.0-040800.201610022031_amd64.deb
dpkg -i linux*4.8*.deb
rm -rf *.deb

############################### OTHER ###############################
# cat <<EOF >  /etc/sysctl.d/k8s.conf
# net.bridge.bridge-nf-call-ip6tables = 1
# net.bridge.bridge-nf-call-iptables = 1
# EOF
# sysctl --system

# # https://github.com/kubernetes/kubernetes/blob/master/build/rpms/50-kubeadm.conf
# cat <<EOF >  /etc/sysctl.d/50-kubeadm.conf
# # The file is provided as part of the kubeadm package
# net.ipv4.ip_forward = 1
# EOF

# # in case of using ipvsadm: https://kubernetes.io/blog/2018/07/09/ipvs-based-in-cluster-load-balancing-deep-dive/
# cat <<EOF >  /etc/modules-load.d/ipvs.conf
# # Load the below modules at boot
# ip_vs_sh
# ip_vs_wrr
# ip_vs_rr
# ip_vs
# nf_conntrack_ipv4
# EOF

#################### KUBEADM PREREQUISITES ##########################

kubeadm config images pull