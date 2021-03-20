provider "aws" {
  region = var.region
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

locals {
  clusters = {
    test1 = {
      allowed_cidr_blocks = "188.25.169.63/32",
    }
  }
}
