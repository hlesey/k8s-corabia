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
    adrian = {
      allowed_cidr_blocks = "1.2.3.4/32",
    }
    victor = {
      allowed_cidr_blocks = "0.0.0.0/0",
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

  instance-ami                = var.instance-ami
  control-plane-instance-type = var.control-plane-instance-type
  node-instance-type          = var.node-instance-type
  node-spot-price             = var.node-spot-price

  k8s-ssh-key      = var.k8s-ssh-key
  k8s-ssh-key-name = var.k8s-ssh-key-name
  k8s-ssh-key-path = var.k8s-ssh-key-path
}