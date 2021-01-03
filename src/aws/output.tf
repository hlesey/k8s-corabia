output "control_plane_public_dns" {
  value = aws_spot_instance_request.control-plane.public_dns
}

output "control_plane_private_dns" {
  value = aws_spot_instance_request.control-plane.private_dns
}