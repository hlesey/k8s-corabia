output "control_plane_public_dns" {
  value = aws_spot_instance_request.control-plane.public_dns
}

output "control_plane_private_dns" {
  value = aws_spot_instance_request.control-plane.private_dns
}

output "node01_public_dns" {
  value = aws_spot_instance_request.node01.public_dns
}

output "node01_private_dns" {
  value = aws_spot_instance_request.node01.private_dns
}

output "node02_public_dns" {
  value = aws_spot_instance_request.node02.public_dns
}

output "node02_private_dns" {
  value = aws_spot_instance_request.node02.private_dns
}
