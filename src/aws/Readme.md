# Useful terraform commands
- for module initialisation:
```terraform
terraform init
```

- for refresh only:
```terraform
terraform apply -refresh-only
```

- for increasing parallelism (defaults to 10):
```terraform
terraform apply -parallelism=30
```

- for handling a single cluster:
```terraform
terraform plan -target=module.clusters[\"cluster1\"]
terraform apply -target=module.clusters[\"cluster1\"]
terraform destroy -target=module.clusters[\"cluster1\"]
```
