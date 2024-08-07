# Nginx ingress controller

The ingress controller is installed via the kubernetes dashboard helm chart.
We are adding few extra objects like:
- extra node port service to expose it via the 30443 (https) and 30080 (http) ports.
- an HPA object to scale it dynamically based on the CPU usage.
