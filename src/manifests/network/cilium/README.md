# Update instructions

Refs: https://docs.cilium.io/en/v1.12/gettingstarted/k8s-install-default/

## Add cilium helm repo

```bash
helm repo add cilium https://helm.cilium.io/
helm repo update
```

## Generate manifests

```bash

helm template cilium cilium/cilium  \
   --version 1.14.4 \
   --namespace kube-system \
   --set ipam.operator.clusterPoolIPv4PodCIDRList="10.244.0.0/16" \
   --set proxy.sidecarImageRegex="ghcr.io/hlesey/cilium/istio_proxy:1.10.3" \
   --set hubble.relay.enabled=true \
   --set hubble.ui.enabled=true > cilium.yaml
```
