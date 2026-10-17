# Headlamp instructions

[Headlamp](https://github.com/kubernetes-sigs/headlamp) replaces the Kubernetes Dashboard,
which was archived upstream in January 2026. It is served at `https://dashboard.<cluster domain>`
through the shared `envoy-gateway` Gateway; log in with the token from `/output/cluster-admin-token`.

Headlamp's image is pulled from `ghcr.io`, so it does not need mirroring to avoid docker.io
rate limits. Metrics Server, previously a subchart of the dashboard, is now its own addon in
`src/addons/metrics-server`.

# Manually render the helm chart

```bash
helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/
helm repo update
helm template headlamp headlamp/headlamp --namespace headlamp --version 0.45.0 -f src/addons/headlamp/helm-values.yaml > src/addons/headlamp/headlamp.yaml
```
