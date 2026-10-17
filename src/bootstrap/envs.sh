# core components
export K8S_VERSION="1.36"  # https://github.com/kubernetes/kubernetes/releases
export K8S_PATCH_VERSION="5"
export CRIO_VERSION="1.36"  # https://github.com/cri-o/cri-o/
export ETCD_VERSION=${ETCD_VERSION:-v3.6.15}  # https://github.com/etcd-io/etcd/releases
# end of core components

# addons (src/addons, installed by control-plane.sh)
export CILIUM_VERSION="1.20.2" # https://github.com/cilium/cilium/releases (supports k8s 1.33-1.36)
export ENVOY_GATEWAY_VERSION="1.9.1" # https://github.com/envoyproxy/gateway/releases (supports k8s 1.33-1.36)
export METRICS_SERVER_VERSION="3.14.0" # https://github.com/kubernetes-sigs/metrics-server/releases
export HEADLAMP_VERSION="0.45.0" # https://github.com/kubernetes-sigs/headlamp/releases
# end of addons

# security tools (installed by secucirty-tools.sh))
export TRIVY_VERSION="0.74.0"  # https://github.com/aquasecurity/trivy/releases
export KUBE_BENCH_VERSION="0.16.0"  # https://github.com/aquasecurity/kube-bench/releases
export SYFT_VERSION="1.33.0"  # https://github.com/anchore/syft/releases
export COSIGN_VERSION="3.1.3"  # https://github.com/sigstore/cosign/releases
export KUBE_LINTER_VERSION="0.8.3"  # https://github.com/stackrox/kube-linter/releases
export SYSDIG_VERSION="0.41.4"  # https://github.com/draios/sysdig/releases
# end of security tools

# cluster config
export NETWORK_PLUGIN="cilium"
export CONTROL_PLANE_IP="192.168.234.100"
export CONTROL_PLANE_PUBLIC_DNS="k8s.local"
export CONTROL_PLANE_PUBLIC_EXTERNAL_DNS="clusterx.qedzone.ro"
export NODE01_IP="192.168.234.101"
export NODE02_IP="192.168.234.102"
export NODE03_IP="192.168.234.103"
export BOOTSTRAP_TOKEN="abcdef.0123456789abcdef"
export KUBECONFIG=/etc/kubernetes/admin.conf
# end of cluster config
