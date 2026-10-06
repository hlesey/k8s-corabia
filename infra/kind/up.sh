#!/usr/bin/env bash
# Create a local k8s-corabia cluster with kind: 1 control-plane + workers and the same addons as
# src/bootstrap/control-plane.sh (Cilium + Hubble, Envoy Gateway, metrics-server, Headlamp, cluster-admin token).
# K8s minor and addon versions are read from src/bootstrap/envs.sh, so kind follows the same pins as AWS.
# kind only publishes some patch versions, so the node image is pinned below per kind release.
#
# Env overrides:
#   CLUSTER_NAME     kind cluster name                    (default: corabia)
#   WORKERS          number of worker nodes               (default: 2)
#   CNI              cilium | kindnet                     (default: cilium; kindnet has no Hubble)
#   GATEWAY          envoy | none                         (default: envoy; binds 127.0.0.1:80 and :443)
#   GATEWAY_DOMAIN   wildcard domain for HTTPRoutes       (default: clusterx.qedzone.ro, point hostnames to 127.0.0.1 in /etc/hosts)
#   NFS              true | false                         (default: true; nfsserver.local on the control-plane)
#   KIND_NODE_IMAGE  kindest/node image                   (default: KIND_DEFAULT_NODE_IMAGE below)

set -euo pipefail

# Node images for each kind release: https://github.com/kubernetes-sigs/kind/releases
KIND_DEFAULT_NODE_IMAGE="kindest/node:v1.36.4@sha256:099e049362a1526b2db71494e1947aae99bd16290d7c895f2b7ea312e3cbfaed"  # kind v0.33.0

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ADDONS="${REPO_ROOT}/src/addons"
OUTPUT="${REPO_ROOT}/output"

# Read only the version pins; sourcing envs.sh would also override KUBECONFIG.
eval "$(grep -E '^export (K8S_VERSION|CILIUM_VERSION|ENVOY_GATEWAY_VERSION|METRICS_SERVER_VERSION|HEADLAMP_VERSION)=' \
    "${REPO_ROOT}/src/bootstrap/envs.sh")"

CLUSTER_NAME="${CLUSTER_NAME:-corabia}"
WORKERS="${WORKERS:-2}"
CNI="${CNI:-cilium}"
GATEWAY="${GATEWAY:-envoy}"
GATEWAY_DOMAIN="${GATEWAY_DOMAIN:-clusterx.qedzone.ro}"
NFS="${NFS:-true}"
KIND_NODE_IMAGE="${KIND_NODE_IMAGE:-${KIND_DEFAULT_NODE_IMAGE}}"
CONTEXT="kind-${CLUSTER_NAME}"

# Keep the same Kubernetes minor version as the AWS cluster
if [[ "${KIND_NODE_IMAGE}" != *":v${K8S_VERSION}."* ]]; then
    echo "${KIND_NODE_IMAGE} does not match K8S_VERSION=${K8S_VERSION} from envs.sh;" \
         "update KIND_DEFAULT_NODE_IMAGE in $0 or set KIND_NODE_IMAGE" >&2
    exit 1
fi

[[ "${CNI}" == "cilium" || "${CNI}" == "kindnet" ]] || { echo "unsupported CNI: ${CNI} (use cilium or kindnet)" >&2; exit 1; }
[[ "${GATEWAY}" == "envoy" || "${GATEWAY}" == "none" ]] || { echo "unsupported GATEWAY: ${GATEWAY} (use envoy or none)" >&2; exit 1; }
[[ "${NFS}" == "true" || "${NFS}" == "false" ]] || { echo "unsupported NFS: ${NFS} (use true or false)" >&2; exit 1; }
for tool in docker kind kubectl helm openssl; do
    command -v "${tool}" > /dev/null || { echo "missing: ${tool}" >&2; exit 1; }
done

# kind names workers <cluster>-worker, <cluster>-worker2, ...; we use <cluster>-node-01, <cluster>-node-02, ...
node_name() { printf '%s-node-%02d\n' "${CLUSTER_NAME}" "$1"; }
k() { kubectl --context "${CONTEXT}" "$@"; }
h() { helm --kube-context "${CONTEXT}" "$@"; }
# Apply an addon manifest with the AWS domain replaced (the repo file is not changed)
apply_with_domain() { sed -e "s'clusterx.qedzone.ro'${GATEWAY_DOMAIN}'g" "$1" | k apply -f -; }

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
$([[ "${GATEWAY}" == "envoy" ]] && cat <<PORTS
  # Envoy runs with hostNetwork on the control-plane (src/addons/envoy-gateway/custom.yaml)
  extraPortMappings:
  - {containerPort: 80, hostPort: 80, listenAddress: 127.0.0.1}
  - {containerPort: 443, hostPort: 443, listenAddress: 127.0.0.1}
PORTS
)
$(for i in $(seq 1 "${WORKERS}"); do cat <<NODE
- role: worker
  kubeadmConfigPatches:
  - |
    kind: JoinConfiguration
    nodeRegistration:
      name: $(node_name "${i}")
NODE
done)
YAML
)"

echo "${config}" | kind create cluster --name "${CLUSTER_NAME}" --image "${KIND_NODE_IMAGE}" --config -

# Rename worker containers to match their Kubernetes node names.
# kind finds its containers by label, so kind delete/load keep working.
for i in $(seq 1 "${WORKERS}"); do
    kind_name="${CLUSTER_NAME}-worker$([[ "${i}" -gt 1 ]] && echo "${i}" || true)"
    docker rename "${kind_name}" "$(node_name "${i}")"
done

# Deploy Cilium CNI
if [[ "${CNI}" == "cilium" ]]; then
    helm repo add cilium https://helm.cilium.io/ > /dev/null
    helm repo update cilium > /dev/null
    h upgrade \
        --install cilium cilium/cilium \
        --namespace kube-system \
        --version "${CILIUM_VERSION}" \
        -f "${ADDONS}/cilium/helm-values.yaml" \
        --wait
fi

k wait --for=condition=Ready nodes --all --timeout=180s

# Same worker labels as infra/aws/k8s/k8s_module (node-labels)
for i in $(seq 1 "${WORKERS}"); do
    k label node "$(node_name "${i}")" kubernetes.io/hostname="$(printf 'node%02d' "${i}")" \
        node-role.kubernetes.io/"$(printf 'node%02d' "${i}")"= --overwrite
done

# As on AWS there is no default StorageClass: PVCs without storageClassName bind to static PVs
# (e.g. k8s-labs/src/storage/pv-nfs.yaml). kind's local-path "standard" class stays available by name.
k annotate storageclass standard storageclass.kubernetes.io/is-default-class- > /dev/null

# NFS server on the control-plane, exported as nfsserver.local:/nfs/pv*, as on AWS
# (src/bootstrap/common.sh hosts entry + src/bootstrap/nfs.sh)
if [[ "${NFS}" == "true" ]]; then
    control_plane="${CLUSTER_NAME}-control-plane"
    control_plane_ip="$(docker inspect -f '{{.NetworkSettings.Networks.kind.IPAddress}}' "${control_plane}")"
    for node in "${control_plane}" $(for i in $(seq 1 "${WORKERS}"); do node_name "${i}"; done); do
        docker exec "${node}" bash -c "
            echo '${control_plane_ip} control-plane control-plane.local nfsserver.local' >> /etc/hosts
            apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -yqq nfs-common > /dev/null"
    done
    # Same layout and export as src/bootstrap/nfs.sh, but the node's root is overlayfs, which nfsd cannot export:
    # /nfs is a tmpfs instead (in memory, lost when the node restarts), which needs an explicit fsid.
    docker exec "${control_plane}" bash -c '
        set -e
        DEBIAN_FRONTEND=noninteractive apt-get install -yqq nfs-kernel-server > /dev/null
        mkdir -p /nfs
        mountpoint -q /nfs || mount -t tmpfs -o size=2g tmpfs /nfs
        mkdir -p /nfs/pv{00..30} /nfs/pv-prom
        chmod -R 777 /nfs
        echo "/nfs *(rw,sync,no_root_squash,subtree_check,fsid=1)" > /etc/exports
        systemctl start nfs-server
        exportfs -ra'
fi

# Deploy Envoy Gateway, Gateway Class and Gateway
if [[ "${GATEWAY}" == "envoy" ]]; then
    h upgrade \
        --install eg oci://docker.io/envoyproxy/gateway-helm \
        --version v"${ENVOY_GATEWAY_VERSION}" \
        -n envoy-gateway \
        --create-namespace \
        -f "${ADDONS}/envoy-gateway/helm-values.yaml" \
        --wait

    # Self-signed wildcard certificate for the Gateway https listener.
    # custom.yaml references Secret "envoy-gateway", but that is Envoy Gateway's own control-plane (xDS) certificate,
    # created by its certgen job: overwriting it breaks the proxy, so use a separate Secret.
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' EXIT
    cat > "${tmp}/openssl.cnf" <<CNF
[req]
distinguished_name = dn
x509_extensions = v3
prompt = no
[dn]
CN = *.${GATEWAY_DOMAIN}
[v3]
subjectAltName = DNS:*.${GATEWAY_DOMAIN},DNS:${GATEWAY_DOMAIN}
CNF
    openssl req -x509 -newkey rsa:2048 -nodes -days 365 -config "${tmp}/openssl.cnf" \
        -keyout "${tmp}/tls.key" -out "${tmp}/tls.crt" 2> /dev/null
    k -n envoy-gateway create secret tls envoy-gateway-tls --cert="${tmp}/tls.crt" --key="${tmp}/tls.key" \
        --dry-run=client -o yaml | k apply -f -

    sed -e "s'clusterx.qedzone.ro'${GATEWAY_DOMAIN}'g" \
        -e '/certificateRefs:/,/name:/ s/name: envoy-gateway$/name: envoy-gateway-tls/' \
        "${ADDONS}/envoy-gateway/custom.yaml" | k apply -f -
    k -n envoy-gateway wait gateway/envoy-gateway --for=condition=Programmed --timeout=180s

    # Deploy Cilium Hubble UI HTTPRoute
    if [[ "${CNI}" == "cilium" ]]; then
        apply_with_domain "${ADDONS}/cilium/custom.yaml"
    fi
fi

# Deploy Metrics Server
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ > /dev/null
helm repo update metrics-server > /dev/null
h upgrade \
    --install metrics-server metrics-server/metrics-server \
    --namespace kube-system \
    --version "${METRICS_SERVER_VERSION}" \
    -f "${ADDONS}/metrics-server/helm-values.yaml"

# Deploy Headlamp
helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/ > /dev/null
helm repo update headlamp > /dev/null
h upgrade \
    --install headlamp headlamp/headlamp \
    --create-namespace \
    --namespace headlamp \
    --version "${HEADLAMP_VERSION}" \
    -f "${ADDONS}/headlamp/helm-values.yaml"
if [[ "${GATEWAY}" == "envoy" ]]; then
    apply_with_domain "${ADDONS}/headlamp/custom.yaml"
fi

# Scale coredns to 1 replica
k -n kube-system scale deployment coredns --replicas=1

# Kubeconfig and lifetime cluster-admin token in output/, as on AWS
mkdir -p "${OUTPUT}"
kind get kubeconfig --name "${CLUSTER_NAME}" > "${OUTPUT}/kubeconfig.yaml"
k apply -f "${ADDONS}/admin-sa/admin-sa.yaml"
k -n default create token --duration=0s cluster-admin > "${OUTPUT}/cluster-admin-token"

k get nodes -o wide
echo "-------------------------------------------------------------"
echo "kubectl context: ${CONTEXT} (also ${OUTPUT}/kubeconfig.yaml)"
echo "Node shell (instead of SSH): docker exec -it <${CLUSTER_NAME}-control-plane|$(node_name 1)|...> bash"
if [[ "${GATEWAY}" == "envoy" ]]; then
    echo "Headlamp:  https://dashboard.${GATEWAY_DOMAIN} (self-signed certificate)"
    if [[ "${CNI}" == "cilium" ]]; then
        echo "Hubble UI: https://hubble-ui.${GATEWAY_DOMAIN}"
    fi
    if [[ "${GATEWAY_DOMAIN}" != *.nip.io ]]; then
        echo "Add to /etc/hosts: 127.0.0.1 dashboard.${GATEWAY_DOMAIN} hubble-ui.${GATEWAY_DOMAIN} phippy.${GATEWAY_DOMAIN} phippy-api.${GATEWAY_DOMAIN}"
    fi
else
    echo "Headlamp:  kubectl -n headlamp port-forward svc/headlamp 8080:80, then http://localhost:8080"
fi
echo "Login token: ${OUTPUT}/cluster-admin-token"
