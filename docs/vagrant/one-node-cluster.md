# Running one node cluster

If you want to run only the control-plane node and be able to schedule Pods on
it, remove the taint:

```bash
cd deploy/vagrant
vagrant up control-plane
vagrant ssh control-plane
kubectl taint nodes control-plane node-role.kubernetes.io/master-
```
