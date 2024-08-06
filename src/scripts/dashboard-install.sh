#!/usr/bin/env bash
# Setup and bootstrap k8s control-plane
set -xe

source /src/scripts/envs.sh

## deploy ingress controller custom objects
kubectl apply -f  /src/manifests/ingress/nginx/custom.yaml

# deploy dashboard helm chart
sed -i -e "s'clusterx.qedzone.ro'${CONTROL_PLANE_PUBLIC_EXTERNAL_DNS}'g" /src/manifests/dashboard/helm-values.yaml

# Add kubernetes-dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update
# Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard --version "${DASHBOARD_VERSION}" -f /src/manifests/dashboard/helm-values.yaml

## deploy dashboard custom objects
kubectl apply -f /src/manifests/dashboard/custom.yaml
