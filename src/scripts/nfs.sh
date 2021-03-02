#!/usr/bin/env bash
# Configure nfs server (on control-plane node)

source /src/scripts/vars.sh

mkdir /nfs
for i in {0..9}; do
    mkdir /nfs/pv0$i
done
for i in {10..30}; do
    mkdir /nfs/pv$i
done

mkdir /nfs/pv-prom
chmod -R 777 /nfs

cat <<EOF > /etc/exports
/nfs *(rw,sync,no_root_squash,subtree_check)
EOF
exportfs -ra

