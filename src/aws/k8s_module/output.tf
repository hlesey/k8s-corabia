output "control_plane_public_dns" {
  value = aws_spot_instance_request.control-plane.public_dns
}

output "control_plane_public_ip" {
  value = aws_spot_instance_request.control-plane.public_ip
}

output "cluster-name" {
  value = var.cluster-name
}