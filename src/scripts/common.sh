#!/usr/bin/env bash

source /src/scripts/vars.txt

# configure /etc/hosts file
echo "$MASTER_IP   master master.local nfsserver.local" >> /etc/hosts
echo "$NODE01_IP   node01 node01.local"                 >> /etc/hosts
echo "$NODE02_IP   node02 node02.local"                 >> /etc/hosts
echo "$NODE03_IP   node03 node03.local"                 >> /etc/hosts


#########################################################
### fix docker driver --> should be moved in template box
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
### fix sshd dns lookup --> should be moved in template box
echo "UseDNS no" >> /etc/ssh/sshd_config
systemctl restart sshd
#########################################################
