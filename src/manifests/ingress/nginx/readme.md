

Copy the following file into nginx.yaml
https://github.com/kubernetes/ingress-nginx/blob/master/deploy/static/provider/baremetal/deploy.yaml

Add `ingressclass.kubernetes.io/is-default-class: "true"` annotation to `nginx` `IngressClass`.
