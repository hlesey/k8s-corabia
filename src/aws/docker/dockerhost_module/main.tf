resource "aws_vpc" "main" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
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
  tags       = { Name = var.dockerhost-name }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.r.id
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "192.168.234.0/24"
  availability_zone       = "${var.region}${var.az}"
  map_public_ip_on_launch = true
  tags                    = { Name = var.dockerhost-name }
}

resource "aws_security_group" "dockerhost" {
  name        = var.dockerhost-name
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id
  tags        = { Name = var.dockerhost-name }
}

resource "aws_security_group_rule" "allow_all_from_self" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.dockerhost.id
  security_group_id        = aws_security_group.dockerhost.id
}

resource "aws_security_group_rule" "allow_ssh_from_admin" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = split(",", var.allowed-cidr-blocks)
  security_group_id = aws_security_group.dockerhost.id
}

resource "aws_security_group_rule" "allow_8080_from_internet" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.dockerhost.id
}

resource "aws_security_group_rule" "allow_8081_from_internet" {
  type              = "ingress"
  from_port         = 8081
  to_port           = 8081
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.dockerhost.id
}

resource "aws_security_group_rule" "allow_all_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.dockerhost.id
}

resource "aws_instance" "dockerhost" {
  availability_zone           = "${var.region}${var.az}"
  ami                         = var.instance-ami
  instance_type               = var.dockerhost-instance-type
  key_name                    = var.ssh-key-name
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.dockerhost.id]
  depends_on                  = [aws_internet_gateway.gw]
  tags                        = { Name = var.dockerhost-name }
}
