terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "acme" {
  server_url = var.acme-server-url
}

# One Let's Encrypt account for all clusters: new accounts are limited to 10 per IP per 3 hours.
resource "tls_private_key" "acme" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "acme_registration" "main" {
  account_key_pem = tls_private_key.acme.private_key_pem
}

locals {
  az_list = ["a", "b", "c"]

  # adjust cluster lists based on your needs
  clusters = {
    cluster0 = {
      allowed_cidr_blocks = "0.0.0.0/0",
      extra_sans          = ["ctf.qedzone.ro"],
    },
    # cluster1 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
    # cluster2 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
    # cluster3 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
    # cluster4 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
    # cluster5 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
    # cluster6 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
    # cluster7 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
    # cluster8 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
    # cluster9 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
    # cluster10 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
    # cluster11 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
    # cluster12 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
    # cluster13 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
    # cluster14 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
    # cluster15 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
    # cluster16 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
    # cluster17 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
    # cluster18 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
    # cluster19 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
    # cluster20 = {
    #   allowed_cidr_blocks = "0.0.0.0/0",
    # },
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

  az                   = local.az_list[tonumber(substr(each.key, 7, 2)) % 3]
  region               = var.region
  allowed-cidr-blocks  = each.value.allowed_cidr_blocks
  extra-sans           = lookup(each.value, "extra_sans", [])
  acme-account-key-pem = acme_registration.main.account_key_pem

  ssh-key-name = var.ssh-key-name
  ssh-key-path = var.ssh-key-path
}
