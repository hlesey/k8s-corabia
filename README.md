# Kuberntes cluster setup with vagrant, VirtualBox and kubeadm

## Usage

### Bring cluster up
```
vagrant up master
vagrant up node01
vagrant up node02
```

### Manage cluster with kubectl
```
vagrant ssh master
kubectl cluster-info
kubectl show nodes
```

### Manage cluster with kube-dashboard
```
Browse to https://192.168.100.100:31001
Use token generated in scripts/cluster_admin_token.txt
```

Enjoi;
