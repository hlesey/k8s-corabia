resource "aws_instance" "dockerhost" {
  availability_zone           = "${var.region}${var.az}"
  ami                         = var.instance-ami
  instance_type               = var.dockerhost-instance-type
  key_name                    = var.ssh-key-name
  subnet_id                   = var.aws_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.vpc_security_group_ids]
  depends_on                  = [var.aws_internet_gateway]
  tags                        = { Name = var.dockerhost-name }
}
