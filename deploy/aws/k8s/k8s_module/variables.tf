variable "cluster-name" {
  description = "Controls the naming of the AWS resources"
}

variable "vpc-cidr" {
  default = "192.168.0.0/16"
}

variable "allowed-cidr-blocks" {
  description = "A comma separated list of CIDR blocks to allow SSH connections from."
}

variable "region" {
}

variable "az" {
}

variable "instance-ami" {
  # Get new AMI from https://cloud-images.ubuntu.com/locator/ec2/
  default     = "ami-02fd062ee104754fc" # Ubuntu Noble Numbat	24.04 LTS for eu-west-1 region, arm64 arch and 	hvm:ebs-ssd-gp3 instance type
  description = "Which ami is used"
}

variable "control-plane-instance-type" {
  default     = "t4g.small"
  description = "Which EC2 instance type to use for the control-plane node"
}

variable "node-instance-type" {
  default     = "t4g.small"
  description = "Which EC2 instance type to use for the worker nodes"
}

variable "ssh-key-path" {
}

variable "ssh-key-name" {
}
