# Update instructions

Refs: https://docs.cilium.io/en/v1.16/gettingstarted/k8s-install-default/

## Add cilium helm repo

```bash
helm repo add cilium https://helm.cilium.io/
helm repo update
```

## Generate manifests

```bash

helm template cilium cilium/cilium  \
   --version 1.16.0 \
   --namespace kube-system \
   -f src/manifests/network/cilium/helm-values.yaml > cilium.yaml
```
