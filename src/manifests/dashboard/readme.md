
Copy the following file into kubernetes dashboard:

https://github.com/kubernetes/dashboard/blob/master/aio/deploy/recommended.yaml

Replace:

```
namespace: kubernetes-dashboard -> namespace: kube-system
namespace=kubernetes-dashboard -> namespace=kube-system
delete namespace object kubernetes-dashboard
```