# Update instructions

Copy the content of the following file into kubernetes dashboard: https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml.

Replace:

- `namespace: kubernetes-dashboard` -> `namespace: kube-system`
- `namespace=kubernetes-dashboard` -> `namespace=kube-system`
- `delete namespace object kubernetes-dashboard`
