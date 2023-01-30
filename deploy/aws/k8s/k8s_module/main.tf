terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
  tags = {
    Name = var.cluster-name
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = var.cluster-name
  }
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name = var.cluster-name
  }
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
  tags = {
    Name = var.cluster-name
  }
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
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.kubernetes.id]
  depends_on                  = [aws_internet_gateway.gw]
  tags = {
    Name = "${var.cluster-name}-control-plane"
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      associate_public_ip_address,
    ]
  }
}

resource "aws_eip" "control-plane" {
  vpc        = true
  instance   = aws_instance.control-plane.id
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name = var.cluster-name
  }
}

resource "null_resource" "control-plane-config" {
  triggers = {
    instance = aws_instance.control-plane.id
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh-key-path)
    host        = aws_eip.control-plane.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir /src /output /repo",
      "sudo chown ubuntu /src /output /repo",
    ]
  }

  provisioner "file" {
    source      = "../../../src/scripts"
    destination = "/src/"
  }

  provisioner "file" {
    source      = "../../../src/manifests"
    destination = "/src/"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo echo 'export CONTROL_PLANE_IP=${aws_eip.control-plane.private_ip}' >> /src/scripts/envs",
      "sudo echo 'export CONTROL_PLANE_PUBLIC_DNS=${aws_eip.control-plane.public_dns}' >> /src/scripts/envs",
      "sudo echo 'export CONTROL_PLANE_PUBLIC_EXTERNAL_DNS=${var.cluster-name}.qedzone.ro' >> /src/scripts/envs",
      "sudo /bin/bash /src/scripts/common.sh",
      "sudo /bin/bash /src/scripts/nfs.sh",
      "sudo /bin/bash /src/scripts/control-plane.sh",
    ]
  }
}

resource "aws_instance" "node" {
  count                       = 2
  availability_zone           = "${var.region}${var.az}"
  ami                         = var.instance-ami
  instance_type               = var.node-instance-type
  key_name                    = var.ssh-key-name
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.kubernetes.id]
  depends_on                  = [null_resource.control-plane-config]
  tags = {
    Name = "${var.cluster-name}-node0${count.index + 1}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh-key-path)
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir /src /output",
      "sudo chown ubuntu /src /output",
    ]
  }

  provisioner "file" {
    source      = "../../../src/scripts"
    destination = "/src/"
  }

  provisioner "file" {
    source      = "../../../src/manifests"
    destination = "/src/"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo echo 'export CONTROL_PLANE_IP=${aws_eip.control-plane.private_ip}' >> /src/scripts/envs",
      "sudo /bin/bash /src/scripts/common.sh",
      "sudo /bin/bash /src/scripts/node.sh",
    ]
  }
}

resource "null_resource" "node-labels" {
  count = 2

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh-key-path)
    host        = aws_eip.control-plane.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf label node $(echo ${aws_instance.node[count.index].private_dns} | cut -d '.' -f1) kubernetes.io/hostname=node0${count.index + 1} --overwrite",
      "sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf label node $(echo ${aws_instance.node[count.index].private_dns} | cut -d '.' -f1) node-role.kubernetes.io/node0${count.index + 1}= --overwrite",
      "sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf label node $(echo ${aws_instance.node[count.index].private_dns} | cut -d '.' -f1) node-role.kubernetes.io/worker= --overwrite"
    ]
  }
}

module "kubeconfig" {
  depends_on = [null_resource.control-plane-config]
  source     = "Invicton-Labs/shell-resource/external"
  command_unix    = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.ssh-key-path} ubuntu@${aws_eip.control-plane.public_ip} sudo sed -e 's#${aws_eip.control-plane.private_ip}#${aws_eip.control-plane.public_dns}#g' /output/kubeconfig.yaml"
  timeout_create = 120
}

module "cluster-admin-token" {
  depends_on = [null_resource.control-plane-config]
  source     = "Invicton-Labs/shell-resource/external"
  command_unix    = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.ssh-key-path} ubuntu@${aws_eip.control-plane.public_ip} sudo cat /output/cluster-admin-token"
}
