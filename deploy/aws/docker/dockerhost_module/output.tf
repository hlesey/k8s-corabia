output "dockerhost_public_dns" {
  value = aws_instance.dockerhost.public_dns
}

output "dockerhost_public_ip" {
  value = aws_instance.dockerhost.public_ip
}

output "dockerhost-name" {
  value = var.dockerhost-name
}
