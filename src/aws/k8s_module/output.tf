output "control_plane_public_dns" {
  value = aws_instance.control-plane.public_dns
}

output "control_plane_public_ip" {
  value = aws_instance.control-plane.public_ip
}

output "cluster-name" {
  value = var.cluster-name
}