#!/usr/bin/env bash

# install and configure NFS server

yum -y install nfs-utils libnfsidmap

systemctl enable rpcbind
systemctl enable nfs-server

systemctl start rpcbind
systemctl start nfs-server
systemctl start rpc-statd
systemctl start nfs-idmapd

mkdir /nfs
chmod 777 /nfs

# (rw,sync,no_subtree_check,no_root_squash)
cat <<EOF > /etc/exports
/nfs 192.168.100.0/24(rw,sync,no_root_squash)
EOF
exportfs -r


for i in {0..4}; do
    mkdir /nfs/pv0$i
done