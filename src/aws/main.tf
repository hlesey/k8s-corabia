provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_key_pair" "main" {
  key_name   = var.k8s-ssh-key-name
  public_key = var.k8s-ssh-key
}

resource "aws_vpc" "main" {
  cidr_block            = "192.168.0.0/16"
  enable_dns_hostnames  = true
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "r" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table_association" "main" {
    subnet_id = aws_subnet.main.id
    route_table_id = aws_route_table.r.id
}

resource "aws_subnet" "main" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = "192.168.234.0/24"
    availability_zone = "${var.region}${var.az}"
    map_public_ip_on_launch = true
}

resource "aws_security_group" "kubernetes" {
  name          = var.cluster-name
  description   = "Allow inbound ssh traffic"
  vpc_id        = aws_vpc.main.id
}

resource "aws_security_group_rule" "allow_all_from_self" {
  type                      = "ingress"
  from_port                 = 0
  to_port                   = 0
  protocol                  = "-1"
  source_security_group_id  = aws_security_group.kubernetes.id
  security_group_id         = aws_security_group.kubernetes.id
}

resource "aws_security_group_rule" "allow_ssh_from_admin" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = split(",", var.allowed-cidr-blocks)
  security_group_id = aws_security_group.kubernetes.id
}

resource "aws_security_group_rule" "allow_k8s_from_admin" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = split(",", var.allowed-cidr-blocks)
  security_group_id = aws_security_group.kubernetes.id
}

resource "aws_security_group_rule" "allow_https_from_web" {
  type              = "ingress"
  from_port         = 30443
  to_port           = 30443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kubernetes.id
}

resource "aws_security_group_rule" "allow_http_from_web" {
  type              = "ingress"
  from_port         = 30080
  to_port           = 30080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kubernetes.id
}

resource "aws_security_group_rule" "allow_all_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kubernetes.id
}

resource "aws_spot_instance_request" "control-plane" {
    availability_zone           = "${var.region}${var.az}"
    ami                         = "ami-0e1ce3e0deb8896d2"
    instance_type               = var.control-plane-instance-type
    spot_price                  = var.control-plane-spot-price
    key_name                    = var.k8s-ssh-key-name
    wait_for_fulfillment        = true
    subnet_id                   = aws_subnet.main.id
    associate_public_ip_address = true
    vpc_security_group_ids      = [aws_security_group.kubernetes.id]
    depends_on                  = [aws_internet_gateway.gw, aws_key_pair.main]
}
