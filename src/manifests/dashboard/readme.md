# Kubernetes dashboard instructions

The upstream helm chart is installing the kubernetes dashboard, but is also configured to install the metrics server and the nginx ingress controller.
We are configuring custom registries for the kubernetes dashboard in `helm-values.yaml` in order to avoid being rate limited by docker.io


# Image mirroring

Adjust the images version in `helm-values.yaml` and run the following commands to mirror the images to the `ghcr.io/hlesey` repository:
```bash
for i in kubernetesui/dashboard-auth:1.1.3 kubernetesui/dashboard-api:1.7.0 kubernetesui/dashboard-web:1.4.0 kubernetesui/dashboard-metrics-scraper:1.1.1; do
  crane copy $i ghcr.io/hlesey/$i
done
```

See https://github.com/google/go-containerregistry/blob/main/cmd/crane/README.md and https://github.com/google/go-containerregistry/blob/main/cmd/crane/doc/crane_copy.md for more details about the `crane` tool.

# Manually render the helm chart
```bash
# Add kubernetes-dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update
# Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
helm template kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --namespace kubernetes-dashboard --version 7.5.0 -f src/manifests/dashboard/helm-values.yaml > src/manifests/dashboard/kubernetes-dashboard.yaml
```
