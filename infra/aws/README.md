# Terraform aws module

## Quota

For 20+ clusters, check the following quotas:

- default region: **aws/eu-west-1**
- Running On-Demand Standard (A, C, D, H, I, M, R, T, Z) instances: **220**
- EC2-VPC Elastic IPs: **30**

## Useful terraform commands

### Module initialisation

```terraform
terraform init
```

### Refresh only

```terraform
terraform apply -refresh-only -parallelism=30
```

### Increase parallelism

You should also increase the open files limit if increasing the terraform parallelism,
in order to avoid:
```bash
│ Failed to initialize pipe for output: pipe: too many open files
```

```bash
ulimit -a
ulimit -n 10240
```
Default terraform parallelism is 10.

```terraform
terraform apply -parallelism=30
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
