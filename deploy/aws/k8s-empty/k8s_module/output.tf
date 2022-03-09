output "control_plane_public_dns" {
  value = aws_instance.control-plane.public_dns
}

output "control_plane_public_ip" {
  value = aws_instance.control-plane.public_ip
}

output "control_plane_private_dns" {
  value = aws_instance.control-plane.private_dns
}

output "control_plane_private_ip" {
  value = aws_instance.control-plane.private_ip
}

output "node_public_dns" {
  value = aws_instance.node.public_dns
}

output "node_public_ip" {
  value = aws_instance.node.public_ip
}

output "cluster-name" {
  value = var.cluster-name
}
