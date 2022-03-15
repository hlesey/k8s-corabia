
Copy the following file into nginx.yaml
https://github.com/kubernetes/ingress-nginx/blob/master/deploy/static/provider/baremetal/deploy.yaml

And `- --watch-ingress-without-class=true` parameter to `nginx-ingress-controller`
