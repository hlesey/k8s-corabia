resource "aws_vpc" "main" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
  tags                 = { Name = var.cluster-name }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = var.cluster-name }
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  depends_on = [aws_internet_gateway.gw]
  tags       = { Name = var.cluster-name }
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
  tags                    = { Name = var.cluster-name }
}

resource "aws_security_group" "kubernetes" {
  name        = var.cluster-name
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id
  tags        = { Name = var.cluster-name }
}

resource "aws_security_group_rule" "allow_all_from_self" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.kubernetes.id
  security_group_id        = aws_security_group.kubernetes.id
}

resource "aws_security_group_rule" "allow_ssh_from_admin" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = split(",", var.allowed-cidr-blocks)
  security_group_id = aws_security_group.kubernetes.id
}

resource "aws_security_group_rule" "allow_k8sapi_from_admin" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = split(",", var.allowed-cidr-blocks)
  security_group_id = aws_security_group.kubernetes.id
}

resource "aws_security_group_rule" "allow_nodeport_from_internet" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
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

resource "aws_instance" "control-plane" {
  availability_zone           = "${var.region}${var.az}"
  ami                         = var.instance-ami
  instance_type               = var.control-plane-instance-type
  key_name                    = var.ssh-key-name
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.kubernetes.id]
  depends_on                  = [aws_internet_gateway.gw]
  tags                        = { Name = "${var.cluster-name}-control-plane" }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh-key-path)
    host        = aws_instance.control-plane.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /src",
      "sudo chown -R ubuntu /src",
    ]
  }

  provisioner "file" {
    source      = "../../../../k8s-labs/src/kubeadm/src/manifests/aws"
    destination = "/src/"
  }
}

resource "aws_instance" "node" {
  availability_zone           = "${var.region}${var.az}"
  ami                         = var.instance-ami
  instance_type               = var.node-instance-type
  key_name                    = var.ssh-key-name
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.kubernetes.id]
  depends_on                  = [aws_internet_gateway.gw]
  tags                        = { Name = "${var.cluster-name}-node" }
}
