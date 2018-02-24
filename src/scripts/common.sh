#!/usr/bin/env bash

source /src/scripts/vars.txt

# configure /etc/hosts file
echo "$MASTER_IP   master master.local nfsserver.local" >> /etc/hosts
echo "$NODE01_IP   node01 node01.local"                 >> /etc/hosts
echo "$NODE02_IP   node02 node02.local"                 >> /etc/hosts
echo "$NODE03_IP   node03 node03.local"                 >> /etc/hosts

# configure external DNS, instead of using VBox DNS
# systemd-resolve --status
echo "DNS=8.8.8.8" >> /etc/systemd/resolved.conf
echo "DNS=8.8.4.4" >> /etc/systemd/resolved.conf
systemctl restart systemd-resolved


#########################################################
### should be moved in template box
### fix docker driver
# Setup daemon.
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

# Restart docker.
systemctl daemon-reload
systemctl restart docker
#########################################################


#########################################################
### should be moved in template box
### fix sshd dns lookup
echo "UseDNS no" >> /etc/ssh/sshd_config
systemctl restart sshd
#########################################################
