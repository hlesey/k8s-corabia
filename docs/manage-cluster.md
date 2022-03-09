# Interact with K8s cluster

## Kubectl

```bash
export KUBECONFIG=$(pwd)/src/output/kubeconfig.yaml
kubectl cluster-info
```

or login into the control-plane node:

```bash
cd deploy/vagrant
vagrant ssh control-plane
kubectl cluster-info
kns <my-fancy-namespace> # change the default namespace in kubeconfig
kubectl get <my-fancy-object>
```

## K8s Dashboard

```bash
Browse to https://192.168.234.100:30443
Use token generated in src/output/cluster-admin-token
```
