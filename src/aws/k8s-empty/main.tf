provider "aws" {
  region = var.region
}

resource "aws_key_pair" "main" {
  key_name   = var.ssh-key-name
  public_key = var.ssh-key
}

locals {
  # adjust cluster lists based on your needs
  clusters = {
    test1-empty = {
      allowed_cidr_blocks = "186.121.5.0/32,193.105.140.131/32",
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

  ssh-key-name = var.ssh-key-name
  ssh-key-path = var.ssh-key-path
}
