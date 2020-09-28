# Running one node cluster

If you want to run only the master node and be able to schedule Pods on it, remove the taint from the master:

```bash
vagrant up master
vagrant ssh master
kubectl taint nodes master node-role.kubernetes.io/master-
```
