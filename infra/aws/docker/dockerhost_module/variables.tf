variable "dockerhost-name" {
  description = "Controls the naming of the AWS resources"
}

variable "vpc-cidr" {
  default = "192.168.0.0/16"
}

variable "aws_subnet_id" {
}

variable "vpc_security_group_ids" {
}

variable "aws_internet_gateway" {
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

variable "dockerhost-instance-type" {
  default     = "t4g.small"
  description = "Which EC2 instance type to use for the dockerhost"
}

variable "ssh-key-path" {
}

variable "ssh-key-name" {
}
