#!/usr/bin/env bash

source /src/scripts/vars.txt

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