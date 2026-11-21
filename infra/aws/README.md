# Terraform aws module

## Gateway TLS certificate

Each cluster gets a Let's Encrypt certificate for `clusterN.qedzone.ro` and `*.clusterN.qedzone.ro`,
issued by Terraform on your machine and copied to the control plane as `/src/tls.crt` and `/src/tls.key`.
`control-plane.sh` loads it into the `envoy-gateway-tls` Secret that the Gateway `https` listener references.
No cert-manager and no Cloudflare credentials ever reach the clusters. A single Let's Encrypt account, shared by
all clusters, is created automatically on first apply with no contact email; nothing to sign up for.

Before `terraform apply`:

```bash
# needs at least Zone:DNS:Edit permission on qedzone.ro domain; the acme provider reads this name
export CLOUDFLARE_DNS_API_TOKEN="xxx"
```

Not so obvious details:

* The DNS-01 challenge only needs a TXT record, so it works before `export.py` points the A records at the new EIPs.
* `cluster0` also gets `ctf.qedzone.ro` as an extra name (`extra_sans` in `main.tf`). That record is a manual CNAME
  to `cluster0.qedzone.ro` in Cloudflare, so it follows the EIP on its own. Add `extra_sans` to any other cluster the same way.
* Let's Encrypt limits: 50 certificates per week for `qedzone.ro`, and 5 per week for the exact same name set.
  While iterating on the bootstrap, point at staging so a broken run does not burn the quota:
  `export TF_VAR_acme-server-url="https://acme-staging-v02.api.letsencrypt.org/directory"` (browsers will warn, that is expected).
* Certificates last 90 days and are not renewed; a `terraform destroy`/`apply` issues fresh ones.
* The DNS propagation pre-check only uses 1.1.1.1 and 8.8.8.8 over IPv4 (`k8s_module/main.tf`). Lego's default also
  asks Cloudflare's authoritative servers over IPv6; on a network with a dead IPv6 path every poll times out and each
  name burns a 2 minute timeout before the order fails. If a certificate sits in `Still creating` for minutes, re-run with
  `TF_LOG_PROVIDER=debug TF_LOG_PATH=/tmp/tf-acme.log` and look for repeated `Waiting for condition failed`.
* The private keys live in `terraform.tfstate` next to the kubeconfigs. Keep the state local, as today.
* The `kind` setup (`infra/kind/up.sh`) keeps a self-signed certificate; DNS-01 cannot validate a cluster behind `/etc/hosts`.


## Bootstrap cluster(s)

Module initialisation
```terraform
terraform init
```

Increase parallelism
```bash
ulimit -a
ulimit -n 10240
```

Export the cloudflare API token:

```bash
# needs at least Zone:DNS:Edit permission on qedzone.ro domain; the acme provider reads this name
export CLOUDFLARE_DNS_API_TOKEN="xxx"
```

Deploy resources (default parallelism=10)
```terraform
terraform apply -parallelism=30
```

## Other operations

### Refresh only

```terraform
terraform apply -refresh-only -parallelism=30
```

### Handling a single cluster

Be aware that you might lose the token and kubeconfig for the other clusters.
Maybe do a backup first.

```terraform
terraform plan -target=module.clusters[\"cluster11\"]
terraform apply -target=module.clusters[\"cluster11\"]
terraform destroy -target=module.clusters[\"cluster10\"] -target=module.clusters[\"cluster11\"]
```

```terraform
terraform apply -refresh-only -target=module.dockerhost[11]
```

## CKS security tools

The CKS tools (trivy, kube-bench, syft, cosign, kube-linter, sysdig, kubesec; `src/bootstrap/security-tools.sh`)
are installed only when `ENABLE_SECURITY_TOOL=true` (default: false) in `src/bootstrap/envs.sh`.

To enable them, set `export ENABLE_SECURITY_TOOL=true` in `src/bootstrap/envs.sh``.

## Possible issues

### Quota

For 20+ clusters, check the following quotas:

- default region: **aws/eu-west-1**
- Running On-Demand Standard (A, C, D, H, I, M, R, T, Z) instances: **220**
- EC2-VPC Elastic IPs: **30**

