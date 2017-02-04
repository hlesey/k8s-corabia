#!/usr/bin/env bash

# https://kubernetes.io/docs/setup/independent/install-kubeadm/

### INITIAL SETUP ###
yum -y install vim net-tools telnet yum-utils psmisc lsof

# remove swap
swapoff $(cat /etc/fstab | grep swap | cut -d ' ' -f1)
sed -e '/swap/ s/^#*/#/' -i /etc/fstab

# disable selinux
setenforce 0
sed 's/SELINUX=enforcing/SELINUX=permissive/g' -i /etc/selinux/config

### INSTALL DOCKER ###
#yum -y install docker

yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y --setopt=obsoletes=0 docker-ce-17.03.0.ce-1.el7.centos docker-ce-selinux-17.03.0.ce-1.el7.centos
systemctl enable docker && systemctl start docker

# Note: Make sure that the cgroup driver used by kubelet is the same as the one used by Docker.
# To ensure compatability you can either update Docker, like so:
# Or ensure the --cgroup-driver kubelet flag is set to the same value as Docker (e.g. cgroupfs).
cat << EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

systemctl restart docker



### INSTALL KUBEADM, KUBELET, KUBECTL ###
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum install -y kubelet kubeadm kubectl kubernetes-cni
systemctl enable kubelet && systemctl start kubelet

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# install crictl
yum -y install go git
go get github.com/kubernetes-incubator/cri-tools/cmd/crictl

# configure /etc/hosts file
echo "192.168.100.100   master master.local k8s.local phippy.local myapp.local nfsserver.local" >> /etc/hosts
echo "192.168.100.101   node01 node01.local" >> /etc/hosts
echo "192.168.100.102   node02 node02.local" >> /etc/hosts
echo "192.168.100.103   node03 node03.local" >> /etc/hosts