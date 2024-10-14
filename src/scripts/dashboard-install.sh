#!/usr/bin/env bash
# Setup and bootstrap k8s control-plane
set -xe

source /src/scripts/envs.sh

## deploy ingress controller custom objects
kubectl apply -f  /src/manifests/ingress/nginx/custom.yaml

# Add kubernetes-dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update

# Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart.
# This will deploy the ingress-nginx controller as well in the ingress-nginx namespace.
helm upgrade \
    --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    --create-namespace --namespace kubernetes-dashboard \
    --version "${DASHBOARD_VERSION}" \
    --set app.ingress.hosts[0]="${CONTROL_PLANE_PUBLIC_EXTERNAL_DNS}" \
    -f /src/manifests/dashboard/helm-values.yaml

## deploy dashboard custom objects
kubectl apply -f /src/manifests/dashboard/custom.yaml
