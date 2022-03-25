# Update instructions

Copy the content of following file into `nginx.yaml`:  https://github.com/kubernetes/ingress-nginx/blob/master/deploy/static/provider/baremetal/deploy.yaml.

Add `- --watch-ingress-without-class=true` parameter to `nginx-ingress-controller`.
