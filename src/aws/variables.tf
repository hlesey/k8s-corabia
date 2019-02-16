variable "k8stoken" {
  default = ""
  description = "Overrides the auto-generated bootstrap token"
}

resource "random_string" "k8stoken-first-part" {
  length = 6
  upper = false
  special = false
}

resource "random_string" "k8stoken-second-part" {
  length = 16
  upper = false
  special = false
}

locals {
  k8stoken = var.k8stoken == "" ? "${random_string.k8stoken-first-part.result}.${random_string.k8stoken-second-part.result}" : var.k8stoken
}

variable "cluster-name" {
  default = "victor"
  description = "Controls the naming of the AWS resources"
}

variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "k8s-ssh-key" {
  default = ""
}

variable "k8s-ssh-key-name" {
  default = "victor-ssh"
}


variable "vpc-cidr" {
  default = "10.0.0.0/16"
}

variable "allowed-cidr-blocks" {
  default = "193.105.140.131/32,193.105.140.132/32"
  description = "A comma separated list of CIDR blocks to allow SSH connections from."
}

variable "region" {
  default = "eu-central-1"
}

variable "az" {
  default = "a"
}

variable "control-plane-instance-type" {
  default = "t3.small"
  description = "Which EC2 instance type to use for the master nodes"
}

variable "control-plane-spot-price" {
  default = "0.01"
  description = "The maximum spot bid for the master node"
}

variable "node-instance-type" {
  default = "t3.micro"
  description = "Which EC2 instance type to use for the worker nodes"
}

variable "node-spot-price" {
  default = "0.01"
  description = "The maximum spot bid for worker nodes"
}
