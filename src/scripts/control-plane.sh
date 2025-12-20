#!/usr/bin/env bash
 
# Setup and bootstrap k8s control-plane components

set -xe
source /src/scripts/envs.sh

# Bootstrap k8s control-plane components
envsubst < /src/cluster-addons/kubeadm/control-plane.yaml > /tmp/control-plane.yaml
kubeadm init --config /tmp/control-plane.yaml > /output/.kubeadmin_init

# Deploy Cilium CNI
helm repo add cilium https://helm.cilium.io/
helm repo update
helm upgrade \
    --install cilium cilium/cilium \
    --namespace kube-system \
    --version "${CILIUM_VERSION}" \
    -f /src/cluster-addons/cilium/helm-values.yaml

# Deploy Envoy Gateway
helm upgrade \
    --install eg oci://docker.io/envoyproxy/gateway-helm \
    --version v"${ENVOY_GATEWAY_VERSION}" \
    -n envoy-gateway \
    --create-namespace \
    -f /src/cluster-addons/envoy-gateway/helm-values.yaml

# Deploy Envoy Gateway Gateway Class and Gateway
sed -i -e "s'clusterx.qedzone.ro'${CONTROL_PLANE_PUBLIC_EXTERNAL_DNS}'g" /src/cluster-addons/envoy-gateway/custom.yaml
kubectl apply -f /src/cluster-addons/envoy-gateway/custom.yaml

# Deploy Cilium Hubble UI HTTPRoute
sed -i -e "s'hubble-ui.clusterx.qedzone.ro'hubble-ui.${CONTROL_PLANE_PUBLIC_EXTERNAL_DNS}'g" /src/cluster-addons/cilium/custom.yaml
kubectl apply -f /src/cluster-addons/cilium/custom.yaml

# Deploy Kubernetes Dashboard
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update
helm upgrade \
    --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    --create-namespace \
    --namespace dashboard \
    --version "${DASHBOARD_VERSION}" \
    --set app.ingress.hosts[0]="${CONTROL_PLANE_PUBLIC_EXTERNAL_DNS}" \
    -f /src/cluster-addons/dashboard/helm-values.yaml

# Deploy Kubernetes Dashboard HTTPRoute
sed -i -e "s'dashboard.clusterx.qedzone.ro'dashboard.${CONTROL_PLANE_PUBLIC_EXTERNAL_DNS}'g" /src/cluster-addons/dashboard/custom.yaml
kubectl apply -f /src/cluster-addons/dashboard/custom.yaml

# Scale coredns to 1 replica
kubectl -n kube-system scale deployment coredns --replicas=1

# Setup cluster-admin service account and generate a lifetime admin token
kubectl apply -f /src/cluster-addons/admin-sa/admin-sa.yaml
kubectl -n default create token --duration=0s cluster-admin > /output/cluster-admin-token

# Final output
ln -s /output/cluster-admin-token /root/cluster-admin-token
echo "-------------------------------------------------------------"
echo "Use this token to login to the kubernetes dashboard:"
cat /root/cluster-admin-token
echo "Enjoy."
