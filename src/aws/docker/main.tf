provider "aws" {
  region = var.region
}

locals {
  # adjust cluster lists based on your needs
  dockerhost = {
    test1 = {
      allowed_cidr_blocks = "0.0.0.0/0",
    }
  }
}

resource "aws_key_pair" "main" {
  key_name   = var.ssh-key-name
  public_key = var.ssh-key
}

module "dockerhost" {
  for_each        = local.dockerhost
  source          = "./dockerhost_module"
  dockerhost-name = each.key

  az                  = var.az
  region              = var.region
  allowed-cidr-blocks = each.value.allowed_cidr_blocks

  ssh-key-name = var.ssh-key-name
  ssh-key-path = var.ssh-key-path
}
