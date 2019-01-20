#!/usr/bin/env bash

cluster_join=""

while [ "$cluster_join" == "" ] ; do
    echo "waiting for the master node";
    sleep 1;
    cluster_join="$(cat /src/output/.kubeadmin_init  | grep 'kubeadm join')"
done

$cluster_join 