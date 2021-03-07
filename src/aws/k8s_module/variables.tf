variable "cluster-name" {
  default     = "victor"
  description = "Controls the naming of the AWS resources"
}

variable "vpc-cidr" {
  default = "192.168.0.0/16"
}

variable "allowed-cidr-blocks" {
  default     = "193.105.140.131/32,193.105.140.132/32,82.77.192.0/24"
  description = "A comma separated list of CIDR blocks to allow SSH connections from."
}

variable "region" {
  default = "eu-central-1"
}

variable "az" {
  default = "a"
}

variable "instance-ami" {
  default     = "ami-0e0102e3ff768559b"
  description = "Which ami is used"
}

variable "control-plane-instance-type" {
  default     = "t3.small"
  description = "Which EC2 instance type to use for the control-plane node"
}

variable "control-plane-spot-price" {
  default     = "0.01"
  description = "The maximum spot bid for the control-plane node"
}

variable "node-instance-type" {
  default     = "t3.micro"
  description = "Which EC2 instance type to use for the worker nodes"
}

variable "node-spot-price" {
  default     = "0.01"
  description = "The maximum spot bid for worker nodes"
}

variable "bootstraptoken" {
  default     = ""
  description = "Overrides the auto-generated bootstrap token"
}

resource "random_string" "bootstraptoken-first-part" {
  length  = 6
  upper   = false
  special = false
}

resource "random_string" "bootstraptoken-second-part" {
  length  = 16
  upper   = false
  special = false
}

locals {
  bootstraptoken = var.bootstraptoken == "" ? "${random_string.bootstraptoken-first-part.result}.${random_string.bootstraptoken-second-part.result}" : var.bootstraptoken
}

variable "k8s-ssh-key-path" {
  default = "~/.ssh/id_rsa_local"
}

variable "k8s-ssh-key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDlT3F3OejZwEishIaViqpbCUyE5TEpga4t2+UKeTWLYWYunPez50YMTTH7jByXFX7Kfbeln5jfk/FKssCKQJKnQCTU4AaRUp1vnWwmsc6ehcrk6/CzKhP073GQwpM2fgCUTNUw5AYJZruMLtcDJwNdZhnr1giajEF983I/ZWu25NpzO9zzSO3WdySMQSIWP7N5W/X/rIyubL2SjJJnCt1UH5zf8HfZiaLArDfauLZGvv30oa9e81TPKvyAklhF0TU+nYHwnL0SQoytsiljjSvpFqCgM9bshuVHXaD/P+FcHYRg9dteT8C5oDPQIVG6w0qkPQyRK9sYkARz37BzuJAkAL9RrWpK5y5FziKOUTA5YHMScVYZLqxS6MVf8Xn6n//w2cahJxWourq2Doyuj0OwgwHNIbDiEZEeN92nAo5iRcwKEKYT5RKjm/+qBufgOVX/4sM6byZ1dn8CHJTZqa2i3mI7KGY3G6QtLE4OlayaJHnAMrnWuKF7azoOv8uzuMIqdutBeDZifp70qUgkVZkTU2Ic8HU+ZQ48X8HuZrlENZ+aV5h7jXJDLVHEqgY6DypDre07oe8AeYkEfUMxtIOjgmkReEanxhA3Oy0q8RqTnr9LCpfqUcy5oLe6zQP3Y3Jy3tg/C7fbVM22N2m5f3TkinQHJF6NW9LZ4QL6wpFogQ=="
}

variable "k8s-ssh-key-name" {
  default = "victor-ssh"
}
