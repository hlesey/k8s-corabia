#!/usr/bin/env bash
# This script installs etcdctl tool

set -xe

# install etcdctl 
curl -L https://github.com/coreos/etcd/releases/download/"$ETCD_VERSION"/etcd-"$ETCD_VERSION"-linux-amd64.tar.gz -o etcd-"$ETCD_VERSION"-linux-amd64.tar.gz
tar xzvf etcd-"$ETCD_VERSION"-linux-amd64.tar.gz
cp etcd-"$ETCD_VERSION"-linux-amd64/etcdctl /usr/local/bin/
rm -rf etcd-*
etcdctl --version
