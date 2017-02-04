#!/usr/bin/env bash

cluster_join=""

while [ "$cluster_join" == "" ] ; do
    echo "waiting for the master node";
    sleep 1;
    cluster_join="$(cat /scripts/.kubeadmin_init  | grep 'kubeadm join')"
done

export PATH=$PATH:/root/go/bin/
$cluster_join --ignore-preflight-errors=cri