provider "aws" {
  region = var.region
}

resource "aws_key_pair" "main" {
  key_name   = var.k8s-ssh-key-name
  public_key = var.k8s-ssh-key
}

locals {
  # adjust cluster lists based on your needs
  clusters = {
    test1 = {
      allowed_cidr_blocks = "186.121.5.0/32",
    }
  }
}

module "clusters" {
  for_each     = local.clusters
  source       = "./k8s_module"
  cluster-name = each.key

  az                  = var.az
  region              = var.region
  allowed-cidr-blocks = each.value.allowed_cidr_blocks

  k8s-ssh-key-name = var.k8s-ssh-key-name
  k8s-ssh-key-path = var.k8s-ssh-key-path
}