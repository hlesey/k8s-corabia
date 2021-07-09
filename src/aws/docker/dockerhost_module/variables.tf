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
  default     = "ami-0c259a97cbf621daf"
  description = "Which ami is used"
}

variable "dockerhost-instance-type" {
  default     = "t3.micro"
  description = "Which EC2 instance type to use for the dockerhost"
}

variable "ssh-key-path" {
}

variable "ssh-key-name" {
}
