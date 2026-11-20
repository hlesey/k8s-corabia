# Terraform aws module

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

