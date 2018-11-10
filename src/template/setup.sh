#!/usr/bin/env bash

# https://kubernetes.io/docs/setup/independent/install-kubeadm/


############################### INITIAL SETUP ###############################

yum -y install vim net-tools telnet yum-utils psmisc lsof

# remove swap
swapoff $(cat /etc/fstab | grep swap | cut -d ' ' -f1)
sed -e '/swap/ s/^#*/#/' -i /etc/fstab

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# supress console warnings
cat <<EOF > /etc/environment
LANG=en_US.utf-8
LC_ALL=en_US.utf-8
EOF


############################### INSTALL DOCKER ###############################

# Install Docker from CentOS/RHEL repository:
# yum install -y docker
# or install Docker CE 18.06 from Docker's CentOS repositories:

## Install prerequisites.
yum -y install yum-utils device-mapper-persistent-data lvm2

## Add docker repository.
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

## Install docker.
yum -y update && yum -y install docker-ce-18.06.1.ce

## Create /etc/docker directory.
mkdir /etc/docker

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
systemctl daemon-reload
systemctl enable docker.service
systemctl restart docker


############################### INSTALL KUBEADM, KUBELET, KUBECTL ###############################

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# yum install -y kubeadm, kubelet and kubectl
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable kubelet && systemctl start kubelet

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system


############################### OTHER ###############################

# https://github.com/kubernetes/kubernetes/blob/master/build/rpms/50-kubeadm.conf
cat <<EOF >  /etc/sysctl.d/50-kubeadm.conf
# The file is provided as part of the kubeadm package
net.ipv4.ip_forward = 1
EOF

# in case of using ipvsadm: https://kubernetes.io/blog/2018/07/09/ipvs-based-in-cluster-load-balancing-deep-dive/
cat <<EOF >  /etc/modules-load.d/ipvs.conf
# Load the below modules at boot
ip_vs_sh
ip_vs_wrr
ip_vs_rr
ip_vs
nf_conntrack_ipv4
EOF
