# Local kind cluster

A local version of k8s-corabia for testing labs (e.g. `cks-preparation`) without AWS.
It runs a kubeadm cluster in Docker containers (1 control-plane and 2 workers by default) with the same addons as
[`src/bootstrap/control-plane.sh`](../../src/bootstrap/control-plane.sh):
Cilium + Hubble, Envoy Gateway, metrics-server, Headlamp and the `cluster-admin` token.

The Kubernetes minor and addon versions come from [`src/bootstrap/envs.sh`](../../src/bootstrap/envs.sh).
kind does not publish every patch version, so `up.sh` pins its own node image
(`KIND_DEFAULT_NODE_IMAGE`, currently `v1.36.4` from kind v0.33.0); it must use the same minor version as `K8S_VERSION`.

## Prerequisites

- Docker
  - macOS: Docker Desktop with at least 8 GB memory in Settings → Resources
  - Linux: your user in the `docker` group (`sudo usermod -aG docker $USER`, then log in again)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation), kubectl, helm and openssl
  (macOS: `brew install kind kubectl helm`)
- Ports 80 and 443 free on `127.0.0.1` (or use `GATEWAY=none`)

## Quick start

1. Add this to `/etc/hosts` (`sudo vi /etc/hosts`):

   ```text
   127.0.0.1 dashboard.clusterx.qedzone.ro hubble-ui.clusterx.qedzone.ro phippy.clusterx.qedzone.ro phippy-api.clusterx.qedzone.ro
   ```

   On macOS, flush the DNS cache afterwards: `sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder`.

2. Create the cluster:

   ```bash
   cd infra/kind
   ./up.sh
   ```

3. Open `https://dashboard.clusterx.qedzone.ro` and log in with the token from `output/cluster-admin-token`.

4. Optionally deploy phippy and open `http://phippy.clusterx.qedzone.ro`:

   ```bash
   kubectl create ns phippy && kubectl apply -f ../../../phippy/kubernetes/app/
   ```

## Usage

```bash
cd infra/kind
./up.sh                          # full setup
CNI=kindnet ./up.sh              # kind's default CNI instead of Cilium (lighter, no Hubble)
GATEWAY=none ./up.sh             # no Envoy Gateway, no host ports 80/443
NFS=false ./up.sh                # no NFS server (skips apt-get installs in the nodes)
WORKERS=1 ./up.sh                # fewer workers
./down.sh                        # delete the cluster
```

Nodes (Kubernetes node names and Docker container names): `corabia-control-plane`, `corabia-node-01`, `corabia-node-02`.
Workers are also labeled `kubernetes.io/hostname=node0N` and `node-role.kubernetes.io/node0N=`, as on AWS.

kind adds the `kind-corabia` context to your kubeconfig; `up.sh` also writes `output/kubeconfig.yaml` and
`output/cluster-admin-token` (the Headlamp login token).

When bumping `K8S_VERSION`, update `KIND_DEFAULT_NODE_IMAGE` with an image (including its digest) listed in the
[kind release notes](https://github.com/kubernetes-sigs/kind/releases), or override it for one run:

```bash
KIND_NODE_IMAGE=kindest/node:v1.36.x@sha256:... ./up.sh
```

## Ingress (Envoy Gateway)

Envoy runs with hostNetwork on `corabia-control-plane` (same `src/addons/envoy-gateway` manifests as AWS),
and kind maps that node's ports 80/443 to `127.0.0.1` on your machine.
The Gateway and HTTPRoutes keep the lab domain `*.clusterx.qedzone.ro`, so lab manifests (e.g. `phippy/kubernetes/app`)
work unchanged. The `https` listener uses a generated self-signed wildcard certificate (accept the browser warning).

### Hosts file

`clusterx.qedzone.ro` is a placeholder (real AWS clusters are `cluster1`, `cluster2`, ...), so point the hostnames
you use to `127.0.0.1`. `/etc/hosts` has no wildcards, so list each one:

```text
# /etc/hosts (macOS: sudo vi /etc/hosts; then sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder)
127.0.0.1 dashboard.clusterx.qedzone.ro hubble-ui.clusterx.qedzone.ro phippy.clusterx.qedzone.ro phippy-api.clusterx.qedzone.ro web.clusterx.qedzone.ro
```

| URL | |
|---|---|
| `https://dashboard.clusterx.qedzone.ro` | Headlamp (token: `output/cluster-admin-token`) |
| `https://hubble-ui.clusterx.qedzone.ro` | Hubble UI |
| `http://phippy.clusterx.qedzone.ro` | phippy UI, after `kubectl create ns phippy; kubectl apply -f phippy/kubernetes/app/` |

To avoid the hosts file, use [nip.io](https://nip.io) (public DNS resolving `*.127.0.0.1.nip.io` to `127.0.0.1`);
lab HTTPRoutes then need their hostnames changed to `*.127.0.0.1.nip.io`:

```bash
GATEWAY_DOMAIN=127.0.0.1.nip.io ./up.sh
```

### Exposing your own app

Attach an HTTPRoute to the `envoy-gateway/envoy-gateway` Gateway:

```bash
kubectl create deployment web --image=nginx:1.27-alpine
kubectl expose deployment web --port=80
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web
spec:
  parentRefs:
  - name: envoy-gateway
    namespace: envoy-gateway
  hostnames:
  - web.clusterx.qedzone.ro
  rules:
  - backendRefs:
    - name: web
      port: 80
EOF
curl http://web.clusterx.qedzone.ro/
kubectl -n envoy-gateway get secret envoy-gateway-tls -o jsonpath='{.data.tls\.crt}' | base64 -d > gateway-ca.crt
curl --cacert gateway-ca.crt https://web.clusterx.qedzone.ro/
```

## Storage (NFS)

As on AWS, `src/bootstrap/nfs.sh` runs on the control-plane and exports `/nfs/pv00` … `/nfs/pv30` as
`nfsserver.local` (added to every node's `/etc/hosts`, as `src/bootstrap/common.sh` does).
There is no default StorageClass either, so PVCs without `storageClassName` bind to static PVs such as
`k8s-labs/src/storage/pv-nfs.yaml`. kind's local-path class is still available as `storageClassName: standard`.

```bash
kubectl apply -f k8s-labs/src/storage/pv-nfs.yaml
kubectl get pv
```

## Differences from the AWS cluster

| AWS (kubeadm + CRI-O) | kind |
|---|---|
| SSH to a node | `docker exec -it corabia-control-plane bash` / `corabia-node-01` / `corabia-node-02` (already root, no `sudo`) |
| CRI-O, container IDs `crio://...` | containerd, container IDs `containerd://...`; `crictl` is available in nodes |
| `*.clusterx.qedzone.ro` resolved by public DNS; the https listener uses Secret `envoy-gateway` (Envoy Gateway's internal xDS certificate) | same hostnames via `/etc/hosts` to `127.0.0.1`; https listener uses Secret `envoy-gateway-tls`, a self-signed wildcard certificate generated by `up.sh` |
| NFS server on the control-plane VM | NFS server in the control-plane container (needs the `nfsd` kernel module on the Linux host / Docker Desktop VM) |
| kubetail installed on the control-plane | install it locally (`brew install kubetail`) |
| Separate kernel per node | all nodes share one kernel (Linux host, or the Docker Desktop VM on macOS) |
| AppArmor available on Ubuntu nodes | Linux host with AppArmor: load profiles on the **host** with `sudo apparmor_parser`. Docker Desktop (macOS): no AppArmor, use AWS for AppArmor labs |
| Sysdig/Falco kernel drivers can be installed on nodes | Linux host only; on Docker Desktop, only in-cluster eBPF (e.g. Falco `modern_ebpf`), if the VM kernel supports it |

`/etc/kubernetes/manifests/*`, `/etc/kubernetes/admin.conf` and `/var/lib/kubelet/config.yaml`
exist in the nodes as on AWS, so kube-bench and the inspection labs work.
To run locally built images in the cluster: `kind load docker-image <image> --name corabia`.
