#!/usr/bin/env bash
# Setup data plane node

source /src/bootstrap/envs.sh

# bootstrap k8s worker
envsubst < /src/addons/kubeadm/worker.yaml > /tmp/worker.yaml
kubeadm join --config /tmp/worker.yaml > /output/.kubeadmin_init
