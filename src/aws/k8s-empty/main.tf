provider "aws" {
  region = var.region
}

locals {
  # adjust cluster lists based on your needs
  clusters = {
    cluster1 = {
      allowed_cidr_blocks = "0.0.0.0/0",
    },
    cluster2 = {
      allowed_cidr_blocks = "0.0.0.0/0",
    },
    cluster3 = {
      allowed_cidr_blocks = "0.0.0.0/0",
    },
    cluster4 = {
      allowed_cidr_blocks = "0.0.0.0/0",
    },
    cluster5 = {
      allowed_cidr_blocks = "0.0.0.0/0",
    },
  }
}

resource "aws_key_pair" "main" {
  key_name   = var.ssh-key-name
  public_key = var.ssh-key
}

module "clusters" {
  for_each     = local.clusters
  source       = "./k8s_module"
  cluster-name = each.key

  az                  = var.az
  region              = var.region
  allowed-cidr-blocks = each.value.allowed_cidr_blocks

  ssh-key-name = var.ssh-key-name
  ssh-key-path = var.ssh-key-path
}
