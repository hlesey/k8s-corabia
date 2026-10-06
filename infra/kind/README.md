# Local kind cluster

A light, local version of k8s-corabia for testing labs (e.g. `cks-preparation`) without AWS.
It runs a kubeadm cluster in Docker containers: 1 control-plane and 1 worker by default.

The Kubernetes minor and Cilium versions come from [`src/bootstrap/envs.sh`](../../src/bootstrap/envs.sh).
kind does not publish every patch version, so `up.sh` pins its own node image
(`KIND_DEFAULT_NODE_IMAGE`, currently `v1.36.4` from kind v0.33.0); it must use the same minor version as `K8S_VERSION`.

## Prerequisites

- Docker
  - macOS: Docker Desktop with at least 4 GB memory (6 GB with Cilium) in Settings → Resources
  - Linux: your user in the `docker` group (`sudo usermod -aG docker $USER`, then log in again)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) and kubectl (macOS: `brew install kind kubectl helm`)
- helm (only for `CNI=cilium`)

## Usage

```bash
infra/kind/up.sh                 # kindnet CNI (supports NetworkPolicy)
CNI=cilium infra/kind/up.sh      # Cilium with src/addons/cilium/helm-values.yaml, Hubble disabled
WORKERS=2 infra/kind/up.sh       # more workers
infra/kind/down.sh               # delete the cluster
```

kind adds the `kind-corabia` context to your kubeconfig.

When bumping `K8S_VERSION`, update `KIND_DEFAULT_NODE_IMAGE` with an image (including its digest) listed in the
[kind release notes](https://github.com/kubernetes-sigs/kind/releases), or override it for one run:

```bash
KIND_NODE_IMAGE=kindest/node:v1.36.x@sha256:... infra/kind/up.sh
```

## Differences from the AWS cluster

| AWS (kubeadm + CRI-O) | kind |
|---|---|
| SSH to a node | `docker exec -it corabia-control-plane bash` / `corabia-worker` (already root, no `sudo`) |
| CRI-O, container IDs `crio://...` | containerd, container IDs `containerd://...`; `crictl` is available in nodes |
| Envoy Gateway, Headlamp, metrics-server, Hubble UI | not installed |
| NFS server and `/nfs/pv*` | `standard` StorageClass (local-path-provisioner) |
| Separate kernel per node | all nodes share one kernel (Linux host, or the Docker Desktop VM on macOS) |
| AppArmor available on Ubuntu nodes | Linux host with AppArmor: load profiles on the **host** with `sudo apparmor_parser`. Docker Desktop (macOS): no AppArmor, use AWS for AppArmor labs |
| Sysdig/Falco kernel drivers can be installed on nodes | Linux host only; on Docker Desktop, only in-cluster eBPF (e.g. Falco `modern_ebpf`), if the VM kernel supports it |

`/etc/kubernetes/manifests/*`, `/etc/kubernetes/admin.conf` and `/var/lib/kubelet/config.yaml`
exist in the nodes as on AWS, so kube-bench and the inspection labs work.
To run locally built images in the cluster: `kind load docker-image <image> --name corabia`.
