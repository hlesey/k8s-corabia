# Update instructions

Copy the content of following file https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml.
Add `- --kubelet-insecure-tls` parameter for  `metrics-server` container.
