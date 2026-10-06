#!/usr/bin/env bash
# Create a light, local k8s-corabia cluster with kind (1 control-plane + workers).
# Versions are read from src/bootstrap/envs.sh, so kind follows the same pins as AWS.
#
# Env overrides:
#   CLUSTER_NAME     kind cluster name                    (default: corabia)
#   WORKERS          number of worker nodes               (default: 1)
#   CNI              kindnet | cilium                     (default: kindnet)
#   KIND_NODE_IMAGE  kindest/node image                   (default: kindest/node:v<K8S_VERSION>.<K8S_PATCH_VERSION>)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Read only the version pins; sourcing envs.sh would also override KUBECONFIG.
eval "$(grep -E '^export (K8S_VERSION|K8S_PATCH_VERSION|CILIUM_VERSION)=' "${REPO_ROOT}/src/bootstrap/envs.sh")"

CLUSTER_NAME="${CLUSTER_NAME:-corabia}"
WORKERS="${WORKERS:-1}"
CNI="${CNI:-kindnet}"
KIND_NODE_IMAGE="${KIND_NODE_IMAGE:-kindest/node:v${K8S_VERSION}.${K8S_PATCH_VERSION}}"

for tool in docker kind kubectl; do
    command -v "${tool}" > /dev/null || { echo "missing: ${tool}" >&2; exit 1; }
done
if [[ "${CNI}" == "cilium" ]]; then
    command -v helm > /dev/null || { echo "missing: helm (required for CNI=cilium)" >&2; exit 1; }
elif [[ "${CNI}" != "kindnet" ]]; then
    echo "unsupported CNI: ${CNI} (use kindnet or cilium)" >&2; exit 1
fi

# Same pod/service subnets as src/bootstrap/kubeadm/control-plane.yaml
config="$(cat <<YAML
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/12
  disableDefaultCNI: $([[ "${CNI}" == "cilium" ]] && echo true || echo false)
nodes:
- role: control-plane
$(for _ in $(seq 1 "${WORKERS}"); do echo "- role: worker"; done)
YAML
)"

echo "${config}" | kind create cluster --name "${CLUSTER_NAME}" --image "${KIND_NODE_IMAGE}" --config -

if [[ "${CNI}" == "cilium" ]]; then
    helm repo add cilium https://helm.cilium.io/ > /dev/null
    helm repo update cilium > /dev/null
    # Repo values, minus Hubble to keep the cluster light
    helm upgrade \
        --install cilium cilium/cilium \
        --kube-context "kind-${CLUSTER_NAME}" \
        --namespace kube-system \
        --version "${CILIUM_VERSION}" \
        -f "${REPO_ROOT}/src/addons/cilium/helm-values.yaml" \
        --set hubble.relay.enabled=false \
        --set hubble.ui.enabled=false \
        --wait
fi

kubectl --context "kind-${CLUSTER_NAME}" wait --for=condition=Ready nodes --all --timeout=180s
kubectl --context "kind-${CLUSTER_NAME}" get nodes -o wide
echo "-------------------------------------------------------------"
echo "kubectl context: kind-${CLUSTER_NAME}"
echo "Node shell (instead of SSH): docker exec -it ${CLUSTER_NAME}-control-plane bash"
