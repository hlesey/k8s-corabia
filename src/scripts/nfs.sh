#!/usr/bin/env bash

# install and configure NFS server

apt-get update
apt-get install -y nfs-kernel-server nfs-common

mkdir /nfs
for i in {0..10}; do
    mkdir /nfs/pv0$i
done
chmod 777 /nfs

# (rw,sync,no_root_squash,subtree_check)
cat <<EOF > /etc/exports
/nfs *(rw,sync,no_root_squash,subtree_check)
EOF
exportfs -ra