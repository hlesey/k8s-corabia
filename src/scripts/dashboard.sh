#!/usr/bin/env bash
# Configure and deploy k8s dashboard

mkdir /tmp/certs

openssl genrsa -out /tmp/certs/dashboard.key 2048
openssl req -x509 -new -nodes -key /tmp/certs/dashboard.key \
        -subj "/CN=k8s.local" -days 365 -out /tmp/certs/dashboard.crt

kubectl --namespace kube-system create secret generic kubernetes-dashboard-certs \
        --from-file=tls.crt=/tmp/certs/dashboard.crt \
        --from-file=tls.key=/tmp/certs/dashboard.key \
        --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f /src/manifests/dashboard/
kubectl apply -f /src/manifests/rbac/rbac.yaml